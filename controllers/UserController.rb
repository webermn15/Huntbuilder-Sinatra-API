class UserController < ApplicationController 

	post '/login' do
		@pw = params[:password]
		@user = User.find_by(username: params[:username])
		if @user && @user.authenticate(@pw)
			session[:username] = @user.username
			session[:logged_in] = true
			session[:user_id] = @user.id
			session[:message] = "Logged in as #{@user.username}"
		else
			session[:message] = "Invalid username or password"
		end

	end

	post '/register' do
		@user = User.new
		@user.username = params[:username]
		@user.password = params[:password]
		@user.email = params[:email]
		@user.save
		session[:logged_in] = true
		session[:username] = @user.username
		session[:user_id] = @user.id
		session[:message] = "You are now logged in."
		p session[:message]
	end


	get '/logout' do
		session[:logged_in] = false
		session[:username] = nil
		session[:user_id] = nil
		session[:message] = "You are now logged out."
	end

	# user profile view
	get '/profile' do 
		# will change to session instead of hardcoding it
		@user = User.find_by(id: 1)
		@hunts = Hunt.where user_id: 1

		resp = {
			user: @user,
			user_hunts: @hunts
		}
		resp.to_json
	end




end