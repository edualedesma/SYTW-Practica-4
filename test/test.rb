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
     before :all do
        @Pagina = "http://www.diariodeavisos.com"
	@Pagina2 = "http://www.eldia.es"
	@ShortPagina = "periodidco"
	@Objeto = ShortenedUrl.first_or_create(:url => "http://www.diariodeavisos.com", :myurl =>'periodico', :username => 'Edu')
	@ObjetoDist = ShortenedUrl.first(:username=> 'Juan')
	
     end
     
     
   
   it "Comprobar que va a la index" do
	  get '/'
	  assert last_response.ok?
    end
    

    it "Comprobar texto correcto" do
		get '/'
		assert_match 'Acortar', last_response.body
    end
   	
    
end
