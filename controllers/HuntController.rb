class HuntController < ApplicationController 

	get '/' do 
		@hunts = Hunt.all
		@hunts.to_json
	end

	get '/:id/participants' do 
		playernames = Array.new
		@participants = Participant.where(hunt_id: params[:id])
		@participants.each do |player|
			this_player = (User.where id: player[:user_id])
			playernames.push(this_player[0].username)
		end
		playernames.to_json
	end

	get '/test' do 
		hints = ["first hint", "second hint", "third hint", "fourth hint"]

		hints.for_each



		qrcode = RQRCode::QRCode.new("#{@hint}")
		# With default options specified explicitly
		png = qrcode.as_png(
          	resize_gte_to: false,
          	resize_exactly_to: false,
          	fill: 'white',
          	color: 'black',
          	size: 120,
          	border_modules: 4,
          	module_px_size: 6,
          	file: "./github-qrcode-test.png"
          	)
		IO.write("./github-qrcode-test.png", png.to_s)
		qrcode.to_json
	end


	post '/qrtest' do 
		# mailgun setup
		mg_client = Mailgun::Client.new 'key-31a5a5277d5cf84faa7a872862674e90'
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
		result = mg_client.send_message('sandboxfb7ea545fb9a434b878152e709415763.mailgun.org', mb_obj)
		puts arr
		
	end



	get '/email' do
		mg_client = Mailgun::Client.new 'key-31a5a5277d5cf84faa7a872862674e90'
		mb_obj = Mailgun::MessageBuilder.new()

		mb_obj.from("webermn15@gmail.com", {"first" => "Michael", "last" => "Weber"})

		mb_obj.add_recipient(:to, "webermn15@gmail.com", {"first" => "Michael", "last" => "Weber"})

		mb_obj.subject("Hunt Builder QR code printouts")

		mb_obj.body_text("Attached you will find QR code pngs named by their hint")

		mb_obj.add_attachment("./github-qrcode-test.png", "QR1.png")

		result = mg_client.send_message('sandboxfb7ea545fb9a434b878152e709415763.mailgun.org', mb_obj)
		puts result.body.to_s
	end

end



























