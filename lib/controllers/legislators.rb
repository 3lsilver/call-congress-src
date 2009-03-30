get "/legislator/:bioguide_id" do
  @leg = Legislator.first(:bioguide_id.eql => params[:bioguide_id])
  if @leg
    @title = "Call Congress | #{@leg.fullname}"
    paginated_calls(params, @leg.bioguide_id)
    filter_links(params)
    @tags = []
    @leg.calls.map{|c| c.tags.each{|t| @tags << t.name}}
    @tags = Set.new(@tags).to_a
    haml :legislator
  else
    error 404
  end
      
end

get "/legislators" do
  @legs = []
  haml :legislators
end


get "/legislators/search" do
  if params.has_key?("state")
    @legs = Legislator.all(:state.eql => params[:state], :in_office => true)
  elsif params.has_key?("zipcode")
    if params[:zipcode].length == 5 
      json_data = open("http://services.sunlightlabs.com/api/districts.getDistrictsFromZip.json?apikey=#{SiteConfig.sunlight_api}&zip=#{params[:zipcode]}").read
      json = JSON.parse(json_data)
      district = json["response"]["districts"][0]["district"]
      state = district["state"]
      dist_num = district["number"]
      @legs = Legislator.all(:state.eql => state)
      @reps = @legs.select{|l| l.district == dist_num.to_i && l.in_office == true}
    end
  elsif params.has_key?("name")
    name1, name2 = params[:name].split("+")
    # Search by last name in both parameter cases
    if name2
      @legs = Legislator.all(:lastname.like => "%#{name2}%")
    else
      @legs = Legislator.all(:lastname.like => "%#{name1}%")    
    end
    # If lastname search didn't get results, search by first name
    if !@legs
      @legs = Legislator.all(:firstname.like => "%#{name1}%")
    end
    # If lastname and firstname didn't get results, return nothing
    if !@legs
      @legs = []
    end
  else
    @legs = []
  end
  if params.has_key?("search")
    @search = true
  end
  @senators ||= @legs.select{|l| l.title == "Sen" && l.in_office == true}
  @reps ||= @legs.select{|l| l.title == "Rep" && l.in_office == true}
  @inactives ||= @legs.select{|l| l.in_office == false}
  
  haml :legislators
end

