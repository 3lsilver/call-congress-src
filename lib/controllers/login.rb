helpers do
  def logged_in?
    return !session[:user_id].nil?
  end
  def cur_user
    return User.first(:id.eql => session[:user_id])
  end
end

get "/login" do
  haml :login
end

post "/login" do
  @user = User.authenticate(params[:username], params[:password])
  unless @user.nil?
    session[:user_id] = @user.id
    redirect "/profile/#{@user.username}"
  else
    flash[:error] = "There was an error. Please try again."
    haml :login
  end
end

get "/logout" do
  session[:user_id] = nil
  redirect "/"
end