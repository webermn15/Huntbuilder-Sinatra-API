class ApplicationController < Sinatra::Base

	require 'bundler'
	Bundler.require

	enable :sessions

	ActiveRecord::Base.establish_connection(
		:adapter => 'postgresql',
		:database => 'item'
	)

	use Rack::MethodOverride  # we "use" middleware in Rack-based libraries/frameworks
	set :method_override, true

	get '/' do 
		'404'
	end

end