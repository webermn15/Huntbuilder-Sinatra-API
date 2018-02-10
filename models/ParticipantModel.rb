class Participant < ActiveRecord::Base

	belongs_to :hunt
	belongs_to :user

end