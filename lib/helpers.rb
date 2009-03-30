class Date
  def ymd
    self.strftime("%m/%d/%Y")
  end
end

class Time
  def ymd
    self.strftime("%m/%d/%Y")    
  end
  def ymdhs
    self.strftime("%m/%d/%Y %H:%M")
  end
end

def can_call_now
  return true
  gmt = Time.now.getgm
  # Weekday - Monday through Friday
  if gmt.wday > 0 && gmt.wday < 6
    # Hour - 8am - 6pm EST
    if gmt.hour < 22 && gmt.hour > 12
      return true
    end
  end
  return false
end

def state_select(name="state", default=true)
  states = %w(AL AK AZ AR CA CO CT DE DC FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY)
  if default
    states.unshift("--")
  end
  out = "<select name=#{name}>"
  states.each do |state|
    out += "<option value='#{state}'>#{state}</option>"
  end
  out += "</select>"
  return out
end

def flash
  session[:flash] = {} if session[:flash] && session[:flash].class != Hash
  session[:flash] ||= {}
end

def haml_flash(*args)
  myhaml = haml(*args)
  flash.clear
  myhaml
end

def params_to_query(queries)
  qs = {}
  queries.each do |q|
    case q[0]
    when "sort"
      qs[:order] = [:created_at.desc] if q[1] == "desc"
      qs[:order] = [:created_at.asc] if q[1] == "asc"
    when "date"
      qs[:created_at.gte] = Date.today if q[1] == "day"
      qs[:created_at.gte] = Date.today - 7 if q[1] == "week"
      qs[:created_at.gte] = Date.today - 31 if q[1] == "month"
    end
  end
  qs[:order] = [:created_at.desc] if !qs.has_key?(:order)
  qs
end

def params_to_selects(queries)
  ss = {}
  queries.each do |q|
    case q[0]
    when "party"
      ss["party"] = q[1].upcase
    when "title"
      ss["title"] = q[1].capitalize
    when "status"
      ss["in_office"] = true if q[1] =~ /^active/
      ss["in_office"] = false if q[1] =~ /inactive/      
    when "tags"
      ss["tags"] = q[1].split(",").map{|t| t.downcase}
    end
  end
  ss
end

def paginated_calls(params, bioguide_id = nil)

  @limit = 5  # CHANGE THIS TO CHANGE PAGINATION RESULTS NUM
  query = {:completed.eql => true, :cancelled => false}
  if params.has_key?("q")
    @queries = params[:q].split("|").map{|q| q.split(":")}
    query = query.merge(params_to_query(@queries))
    selects = params_to_selects(@queries)
  else
    query = query.merge({:order => [:created_at.desc]})
    selects = nil
  end  
  if bioguide_id
    query = query.merge({:legislator_bioguide_id.eql => bioguide_id})
  end
  @all_calls = Call.all(query)
  if selects
    selects.each do |select, val|
      if select == "tags"
        val.each do |tag|
          @all_calls = @all_calls.select{|c| c.tags.map{|t| t.name}.include?(tag)}
        end
      else
        @all_calls = @all_calls.select{|c| c.legislator.send(select) == val} unless val =~ /all/i
      end
    end
  end
  if params.has_key?("p")
    @cur_page = params[:p].to_i
  else
    @cur_page = 1
  end
  if @all_calls.size % @limit == 0
    @pages = @all_calls.size / @limit
  else
    @pages = (@all_calls.size / @limit) + 1 
  end
  if @cur_page < 1 || @cur_page > @pages.size
    @cur_page = 1
    @next_page = 2
  else
    if @pages > @cur_page
      @next_page = @cur_page + 1
    end
    if @cur_page > 1
      @prev_page = @cur_page - 1
    end
  end




  @offset = @cur_page * @limit - @limit
  paginate_hash = {:limit => @limit, :offset => @offset}
  @calls = @all_calls[@offset, @limit]

  if !@next_page.nil?
    @next_link = "?q=#{params[:q]}&p=#{@next_page}"
    @result_string = "#{@offset+1} - #{@offset+@limit} of #{@all_calls.size}"
  else
    @result_string = "#{@offset+1} - #{@all_calls.size} of #{@all_calls.size}"    
  end
  if !@prev_page.nil?
    @prev_link = "?q=#{params[:q]}&p=#{@prev_page}"
  end
end



def filter_link(queries, param, label, value)
  queries = queries.to_hash
  if queries.has_key?(param) && queries[param] == value
    selected = true
  elsif !queries.has_key?(param) && (value == "all" || value == "desc")
    selected = true
  end

  queries[param] = value
  query_string = queries.to_a.map{|q| q[0].to_s+":"+q[1].to_s}.join("|")
  link = "<a "
  link += "class='selected' " if selected
  link += "href='?p=1&q=#{query_string}'>#{label}</a>"
end

def no_tags_link
  qs = env["QUERY_STRING"]
  qs.gsub!(/tags:[^|]*/, "")
  return env["REQUEST_PATH"].to_s + "?" + qs.to_s
end

def filter_tag_link(queries, tag)
  queries = queries.to_hash
  if queries.has_key?("tags")
    tags = queries["tags"].split(",")
    if tags.include?(tag)
      selected = true
      tags.delete(tag)
    else
      tags << tag
    end
    if tags.size == 0
      queries.delete("tags")
    else
      tags = tags.join(",")
      queries["tags"] = tags
    end
  else
    queries["tags"] = tag
  end
  query_string = queries.to_a.map{|q| q[0].to_s+":"+q[1].to_s}.join("|")
  link = "<a "
  link += "class='selected' " if selected
  link += "href='?p=1&q=#{query_string}'>#{tag}</a>"  
end



def filter_links(params)
  if params.has_key?("q")
    queries = params[:q].split("|").map{|q| q.split(":")}
  else
    queries = {}
  end
  @sort_links = []
  sorts = {"Recent First" => "desc", "Oldest First" => "asc"}
  ["Recent First", "Oldest First"].each do |k|
    @sort_links << filter_link(queries.dup, "sort", k, sorts[k])
  end

  @date_links = []
  dates = {"ALL" => "all", "Month" => "month", "Week" => "week", "Day" => "day"}
  %w(ALL Month Week Day).each do |k|
    @date_links << filter_link(queries.dup, "date", k, dates[k])
  end

  @party_links = []
  parties = {"ALL" => "all", "Dem" => "D", "Repub" => "R", "Ind" => "I"}
  %w(ALL Dem Repub Ind).each do |k|
    @party_links << filter_link(queries.dup, "party", k, parties[k])
  end
  
  @title_links = []
  titles = {"ALL" => "all", "Senator" => "sen", "Rep" => "rep"}
  %w(ALL Senator Rep).each do |k|
    @title_links << filter_link(queries.dup, "title", k, titles[k])
  end
  
  @status_links = []
  statuses = {"ALL" => "all", "In Office" => "active", "Out of Office" => "inactive"}
  ["ALL", "In Office", "Out of Office"].each do |k|
    @status_links << filter_link(queries.dup, "status", k, statuses[k])
  end

  @tag_links = []
  tags = {}
  # If this is the legislator page, it will have bioguide_id in params from url
  if params.has_key?("bioguide_id")
    Legislator.first(:bioguide_id.eql => params[:bioguide_id]).tags.map{|t| tags[t.name] = t.name}
  else
    Tag.all.map{|t| tags[t.name] = t.name}    
  end
  tags.keys.sort.each do |tag|
    @tag_links << filter_tag_link(queries.dup, tag)
  end

end
