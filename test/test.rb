ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'test/unit'
require_relative '../app.rb'

include Test::Unit::Assertions


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
		assert_match 'Acortar', last_response.body
    end
   	
    
end
