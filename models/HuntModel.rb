class Hunt < ActiveRecord::Base

	belongs_to :user
	has_many :participants
	has_many :users, :through => :participants

end