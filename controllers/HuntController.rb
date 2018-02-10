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

end