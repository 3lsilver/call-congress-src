get "/calls" do
  paginated_calls(params)
  filter_links(params)
  @tags = Tag.all.map{|t| t.name}
  haml :calls
end

get "/call/new" do
  @user = cur_user
  haml :call_new
end

get "/call/new/:bioguide_id" do
  @user = cur_user
  @leg = Legislator.first(:bioguide_id.eql => params[:bioguide_id])
  if @leg
    haml :call_new
  else
    error 404
  end

end


get "/call/edit/:id" do
  @user = cur_user
  if @user.nil?
    redirect "/call/#{params[:id]}"
  end

    @call = Call.first(:unique_id.eql => params[:id])
  if @call
    if @user.username == @call.user.username
      @tags = @call.tags.map{|t| t.name}.join(" ")
      if params.has_key?("new")
        flash[:notice] = "Congratulations - you called Congress! Edit the call details below."
      end  
      haml :call_edit
    else
      redirect "/call/#{params[:id]}"
    end
  else
    error 404
  end
end

post "/call/edit/:id" do
  @user = cur_user
  if @user.nil?
    redirect "/call/#{params[:id]}"
  end
  @call = Call.first(:unique_id.eql => params[:id])

  if @user.username == @call.user.username
    if params.has_key?("commentary")
      @call.commentary = params[:commentary]
    end
    if params.has_key?("tags")
      CallTag.all(:call_id => @call.unique_id).each {|ct| ct.destroy}
      params[:tags].split(" ").each do |tag|
        t = Tag.first_or_create(:name => tag)
        ct = CallTag.first_or_create(:tag_id => t.id, :call_id => @call.unique_id)
      end
    end
    if @call.save
      flash[:notice] = "The call info was updated."
      redirect "/call/#{@call.unique_id}"
    else
      flash[:error] = "There was an error - please try again"
      haml :call_edit
    end
  else
    redirect "/call/#{params[:id]}"
  end
end


post "/call/place" do
  @user = cur_user
  @call = Call.new(:phone_id => params[:phone_id].to_i, :legislator_bioguide_id => params[:bioguide_id], :user_id => @user.id)
  puts "CALL: #{@call.id}"
  if @call.save
    placed_call = Spork.spork do
      @call.place
    end
    redirect "/call/current/#{@call.unique_id}"
  else
    flash[:error] = "There was an error. Please try again."
    redirect "/call/new/#{params[:bioguide_id]}"
  end
end

get "/call/current/:id" do
  @user = cur_user
  @call = Call.first(:unique_id.eql => params[:id])
  if @call
    if @call.completed == true
      redirect "/call/#{params[:id]}"
    else
      haml :call_current
    end
  else
    error 404
  end
end

get "/call/status/:id" do
  @call = Call.first(:unique_id.eql => params[:id])
  content_type "application/json"
  {:status => @call.status.short_desc, :description => @call.status.description , :completed => @call.completed, :cancelled => @call.cancelled}.to_json
end

post "/call/add_comment/:id" do
  @call = Call.first(:unique_id.eql => params[:id])
  if params[:comment]
    @comment = CallComment.new(:user_id => params[:user_id].to_i, :comment => params[:comment], :call_id => @call.id)
    if @comment.save
      flash[:notice] = "Your comment was saved."
    else
      flash[:error] = "There was an error - please enter your comment again."
    end
  else
    flash[:error] = "Comment text cannot be empty."
  end
  redirect "/call/#{params[:id]}"
end

get "/call/:id" do
  @call = Call.first(:unique_id.eql => params[:id])
  if @call
    if @call.completed == true && @call.cancelled == false
      @leg = @call.legislator
      @title = "Call Congress | Call to: #{@leg.title} #{@leg.fullname}"
      haml :call
    else
      redirect "/call/new"
    end
  else
    error 404
  end
end
