class UserController < ApplicationController 

	get '/' do 
		@users = User.all
		@users.to_json
	end

	get '/:id/hunts' do 
		@hunts = Hunt.where user_id: params[:id]
		@hunts.to_json
	end





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






	post '/qrtest' do 
		# mailgun setup
		mg_client = Mailgun::Client.new ''
		mb_obj = Mailgun::MessageBuilder.new()
		# mailgun send options
		mb_obj.from("webermn15@gmail.com", {"first" => "Michael", "last" => "Weber"})
		mb_obj.add_recipient(:to, "webermn15@gmail.com", {"first" => "Michael", "last" => "Weber"})
		mb_obj.subject("Hunt Builder QR code printouts")
		mb_obj.body_text("Attached you will find QR code pngs named by their hint")

		arr = params.values
		arr.each do |value|
			qrcode = RQRCode::QRCode.new("#{value}")

			png = qrcode.as_png(
	          	resize_gte_to: false,
	          	resize_exactly_to: false,
	          	fill: 'white',
	          	color: 'black',
	          	size: 240,
	          	border_modules: 4,
	          	module_px_size: 6,
	          	file: "./#{value}.png"
	          	)
			IO.write("./#{value}.png", png.to_s)

			mb_obj.add_attachment("./#{value}.png")
		end
		result = mg_client.send_message('', mb_obj)
		puts arr
		
	end


end