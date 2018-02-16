class HuntController < ApplicationController 

	# distance calculation function
	def distance loc1, loc2
		rad_per_deg = Math::PI/180  # PI / 180
		rkm = 6371                  # Earth radius in kilometers
		rm = rkm * 1000             # Radius in meters

		dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
		dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

		lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
		lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

		a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
		c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

		rm * c # Delta in meters
	end

	# view all hunts & sort them by distance
	get '/' do 
		# # declares user location (session!!! eventually) and rounds it for use in activerecord query below
		user_loc = [50.2, -89.5]# will use session data to get user location or something i dont know man
		# user_loc.map! {|i| i.round}

		# # this some code that rounds user lat and the hunt lat stored in it's table and compares them to return nearby results
		# # but i can't get it to work for both lat and long at the same time :( wait actually i can using Postgis, but I need to set up
		# # the activerecord postgis adapter gem
		# @hunts = Hunt.find_by_sql("SELECT * FROM hunts WHERE ROUND(lat, 0) = #{user_loc[0]}")
		# @hunts.to_json

		@hunts = Hunt.all.to_json

		distance_from = Array.new

		hunts = JSON.parse(@hunts).each do |hunt| 
			hunt.symbolize_keys!

			hunt_loc = [hunt[:lat].to_f, hunt[:long].to_f]

			user_hunt_distance = distance(user_loc, hunt_loc)

			test_hash = [hunt,user_hunt_distance]

			distance_from.push(test_hash)
		end
		distance_from.sort! {|a,b| a[1] <=> b[1]}
		distance_from.map! {|i| i.shift}

		resp = {
			sorted_closest: distance_from,
			unsorted: hunts
		}.to_json
	end

	# view one hunt
	get '/:id/view' do 
		user_id = session[:user_id]
		@hunt = Hunt.find_by_id params[:id]
		@creator = User.find_by_id @hunt.user_id
		@participant = Participant.where("hunt_id = ? AND user_id = ?", @hunt.id, user_id).to_json
		pp @participant
		resp = {
			hunt: @hunt,
			creator: @creator
		}.to_json
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
		params.symbolize_keys!
		search_term = params[:keyword]
		results = Hunt.where("description like ?", "%" + search_term + "%")
		# title_results = Hunt.where("title like ?", "%" + search_term + "%")
		
		if results.length < 1
			success = false
		else
			success = true
		end
		p success

		resp = {
			results: results,
			success: success
			# title_search: title_results
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
		parsed_hints = obj[:hints]
		@hunt.hints = parsed_hints
		range = [*'0'..'9',*'a'..'z']
		vict_code = Array.new(10){ range.sample }.join
		@hunt.victory_code = vict_code
		@hunt.hints.push("Congratulations! Enter this code to complete #{@hunt.title}! => " + vict_code)

		# location data this may change
		@hunt.lat = obj[:latitutde]
		@hunt.long = obj[:longitude]
		@hunt.zoom = obj[:zoom]
		@hunt.save
		@hunt.to_json
	end

	# route used to generate QR codes, save them, attach them to email, send to user, and then delete the saved PNG QR codes afterwards
	# needs to get set up using session data
	get '/:id/emailcodes' do 
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
		num_str_arr = ["#{@hunt[:title]} - #1","#{@hunt[:title]} - #2","#{@hunt[:title]} - #3","#{@hunt[:title]} - #4","#{@hunt[:title]} - #5","#{@hunt[:title]} - #6","#{@hunt[:title]} - #7","#{@hunt[:title]} - #8","#{@hunt[:title]} - #9","#{@hunt[:title]} - #10", "#{@hunt[:title]} - #11"]
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







