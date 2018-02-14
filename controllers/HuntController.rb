class HuntController < ApplicationController 

	get '/bigtest' do 
		pp 'it actually worked lmao'
	end





	# view all hunts
	get '/' do 
		@hunts = Hunt.all
		@hunts.to_json
	end

	# view one hunt
	get '/:id/view' do 
		@hunt = Hunt.find_by_id params[:id]
		@hunt.to_json
	end

	# view all participants of a hunt
	get '/:id/participants' do 
		@participants = Participant.where hunt_id: params[:id]
		@participants.to_json
	end

	# post route for when a user selects and begins a hunt
	post '/:id/play' do 
		@hunt = Hunt.find_by_id(params[:id])
		@participant = Participant.new
		@participant.user_id = 1 # will use sessions later
		@participant.hunt_id = params[:id]
		@participant.hints_found = [@hunt[:hints][0]]
		@participant.completed = true
		@participant.save
		@participant.to_json
	end

	# simple get route for displaying participants who have completed a hunt
	get '/:id/completed' do 
		playernames = Array.new
		@participants = Participant.where("hunt_id = ? AND completed = ?", params[:id], 't')
		@participants.each do |player|
			this_player = (User.where id: player[:user_id])
			playernames.push(this_player[0].username)
		end
		playernames.to_json
	end

	# search bar logic for the landing pages 'find hunts' functionality
	post '/search' do 
		search_term = params[:keyword]
		descrip_results = Hunt.where("description like ?", "%" + search_term + "%")
		title_results = Hunt.where("title like ?", "%" + search_term + "%")
		resp = {
			description_search: descrip_results,
			title_search: title_results
		}.to_json
	end


	# hunt creation route, u already know
	post '/new' do 

		@hunt = Hunt.new
		obj = params.symbolize_keys!
		@hunt.title = obj[:title]
		@hunt.description = obj[:description]
		@hunt.user_id = 1 # will use session[:user_id]

		# formatting hints array and injecting victory code at the end
		parsed_hints = JSON.parse obj[:hints]
		@hunt.hints = parsed_hints
		range = [*'0'..'9',*'a'..'z']
		vict_code = Array.new(10){ range.sample }.join
		@hunt.victory_code = vict_code
		@hunt.hints.push(vict_code)

		# location data this may change
		@hunt.lat = obj[:lat]
		@hunt.long = obj[:long]
		@hunt.zoom = obj[:zoom]
		@hunt.save
		@hunt.to_json

	end

	# route used to generate QR codes, save them, attach them to email, send to user, and then delete the saved PNG QR codes afterwards
	# needs to get set up using session data
	get '/:id/printcodes' do 
		# mailgun setup
		mg_client = Mailgun::Client.new ''
		mb_obj = Mailgun::MessageBuilder.new()
		# mailgun send options -- will use session data for all this, hardcoding now for testing purposes
		mb_obj.from("webermn15@gmail.com", {"first" => "Michael", "last" => "Weber"}) #change this to huntbuilder once off sandbox server
		mb_obj.add_recipient(:to, "webermn15@gmail.com", {"first" => "Michael", "last" => "Weber"}) # session[:email], session[:username]
		mb_obj.subject("Hunt Builder QR code printouts")
		mb_obj.body_text("Attached you will find QR code pngs named by their hint")

		@hunt = Hunt.find_by_id params[:id]
		hints = @hunt[:hints]
		num_str_arr = ["#{@hunt[:title]} - one","#{@hunt[:title]} - two","#{@hunt[:title]} - three","#{@hunt[:title]} - four","#{@hunt[:title]} - five","#{@hunt[:title]} - six","#{@hunt[:title]} - seven","#{@hunt[:title]} - eight","#{@hunt[:title]} - nine","#{@hunt[:title]} - ten"]
		inc = 0

		hints.each do |value|
			qrcode = RQRCode::QRCode.new("#{value}")

			png = qrcode.as_png(
	          	resize_gte_to: false,
	          	resize_exactly_to: false,
	          	fill: 'white',
	          	color: 'black',
	          	size: 240,
	          	border_modules: 4,
	          	module_px_size: 6,
	          	file: "./#{num_str_arr[inc]}.png"
	          	)
			IO.write("./#{num_str_arr[inc]}.png", png.to_s)

			mb_obj.add_attachment("./#{num_str_arr[inc]}.png")
			File.delete("./#{num_str_arr[inc]}.png")
			inc = inc + 1
		end

		result = mg_client.send_message('', mb_obj)
		p hints
	end


end







