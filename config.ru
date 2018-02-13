require 'sinatra/base'
require 'sinatra/activerecord'


#Controllers
require './controllers/ApplicationController'
require './controllers/HuntController'
require './controllers/UserController'

#Models
require './models/UserModel'
require './models/HuntModel'
require './models/ParticipantModel'

map('/') {
	run ApplicationController
}
map('/hunts') {
	run HuntController
}
map('/users') {
	run UserController
}