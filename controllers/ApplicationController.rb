class ApplicationController < Sinatra::Base

	require 'bundler'
	Bundler.require

	enable :sessions

	register Sinatra::CrossOrigin

	ActiveRecord::Base.establish_connection(
 		:adapter => 'postgresql', 
 		:database => 'hunttest'
	)

	configure do
		enable :cross_origin
	end

	set :allow_origin, :any
	set :allow_methods, [:get, :post, :options, :put, :delete]
	set :allow_credentials, true

	options "*" do
		response.headers["Allow"] ="HEAD, GET, PUT, POST, DELETE, OPTIONS"
		response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
	end

	include BCrypt

	use Rack::MethodOverride
	set :method_override, true

	not_found do 
		halt 404
	end

end