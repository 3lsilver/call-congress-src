get "/register" do
  haml :register
end

post "/register" do
  if params[:password] != params[:password_confirm]
    flash[:error] = "You must confirm your password."
    haml :register
  elsif params[:password] == ""
    flash[:error] = "The password must not be blank"
    haml :register
  elsif params[:username] == ""
    flash[:error] = "Username cannot be blank"
    haml :register
  elsif User.first(:username.eql => params[:username])
    flash[:error] = "That username already exists. Please try another one."
    haml :register
  elsif params[:email] == ""
    flash[:error] = "Email cannot be blank"
    haml :register
  else
    @user = User.create(:username => params[:username].downcase,
                        :email => params[:email],
                        :password => params[:password],
                        :fullname => params[:fullname])
    if @user.save
      session[:user_id] = @user.id
      if params[:phone] != ""
        num = params[:phone].gsub!(/[^\d]/, "").to_i
        @phone = Phone.create(:number => num, :user_id => @user.id)
        if @phone.save
          session[:user_id] = @user.id
          redirect "/profile/#{@user.username}"
        else
          flash[:error] = "There was an error adding your phone. Please try again"
          redirect "/profile/edit/#{@user.username}"
        end
      end
    else
      flash[:error] = "There was an error. Please try again."
      haml :register
    end
  end
end

get "/profile/:username" do
  @user = User.first(:username.eql => params[:username].downcase)
  if @user
    @calls = @user.calls.select{|c| c.completed == true && c.cancelled == false}
    haml :profile
  else
    error 404
  end
end

get "/profile/edit/:username" do
  @user = cur_user
  if @user.nil?
    redirect "/profile/#{params[:username]}"
  end
  if @user.username != params[:username].downcase
    redirect "/profile/#{params[:username]}"
  else
    @user = cur_user
    haml :profile_edit
  end
end

post "/profile/edit/:username" do
  @user = cur_user
  if @user.nil?
    redirect "/profile/#{params[:username]}"
  end
  if @user.username != params[:username].downcase
    redirect "/profile/#{params[:username]}"
  else
    @user = cur_user
    @user.fullname = params[:fullname]
    @user.email = params[:email]
    @user.save
    
    if params[:password] != ""
      if params[:password_confirm] 
        if params[:password] == params[:password_confirm]        
          @user.password = params[:password]
          if @user.save
            flash[:notice] = "Your profile was saved and your password was changed."
          else
            flash[:error] = "There was an error saving your password"
          end
        else
          flash[:error] = "Password and Confirmation must match"
        end
      else
        flash[:error] = "You must confirm your password"
      end
    else
      flash[:notice] = "Your profile was saved"
    end
    haml :profile_edit
  end
end

post "/profile/edit/phone/add" do
  @user = cur_user
  if @user.nil?
    redirect "/profile/#{params[:username]}"
  end
  num = params[:phone].gsub!(/[^\d]/, "").to_i
  if Phone.first(:number.eql => num)
    @calls = @user.calls
    flash[:error] = "That phone number belongs to another user."
    redirect "/profile/edit/#{@user.username}"
  elsif @user.add_phone(num)
    redirect "/profile/edit/#{@user.username}"
  else
    flash[:error] = "There was an error - try again"
    redirect "/profile/edit/#{@user.username}"
  end
end



get "/profile/edit/phone/delete/:id" do
  @user = cur_user
  if @user.nil?
    redirect "/profile/#{params[:username]}"
  end  
  if @user.remove_phone(params[:id])
    redirect "/profile/edit/#{@user.username}"
  else
    flash[:error] = "There was an error deleting your phone."
    redirect "/profile/edit/#{@user.username}"
  end
end

get "/profile/edit/phone/make_primary/:id" do
  @user = cur_user
  if @user.nil?
    redirect "/profile/#{params[:username]}"
  end
  @phone = Phone.first(:id.eql => params[:id], :user_id => @user.id)
  @phone.make_primary
  redirect "/profile/edit/#{@phone.user.username}"
end