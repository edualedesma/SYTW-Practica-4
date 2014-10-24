ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
#require 'rack/test'
require_relative '../app.rb'

include Rack::Test::Methods

def app
	Sinatra::Application
end

describe 'Tests de app.rb' do
    it "Comprobar que va a la index" do
	  get '/'
	  assert last_response.ok?
    end
    

    it "Comprobar texto correcto" do
		get '/'
		assert_match 'Acorta esta url:', last_response.body
    end
   	
    
end