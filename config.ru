require 'sinatra/base'
require 'sinatra/activerecord'

#Controllers
require './ApplicationController'

map ('/') {
	run ApplicationController
}