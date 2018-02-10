class UserController < ApplicationController 

	get '/' do 
		@users = User.all
		@users.to_json
	end

	get '/:id/hunts' do 
		@hunts = Hunt.where user_id: params[:id]
		@hunts.to_json
	end

end