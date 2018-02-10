class User < ActiveRecord::Base

	has_many :hunts
	has_many :participants
	has_many :hunts, :through => :participants

end