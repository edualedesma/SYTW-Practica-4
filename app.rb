#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'uri'
require 'pp'
#require 'socket'
require 'data_mapper'

require 'bundler/setup'
require 'omniauth-oauth2'
require 'omniauth-google-oauth2'
require 'pry'
require 'erubis'


DataMapper.setup( :default, ENV['DATABASE_URL'] || 
                            "sqlite3://#{Dir.pwd}/my_shortened_urls.db" )
DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize

#DataMapper.auto_migrate!
DataMapper.auto_upgrade!

Base = 36


#**** AUTENTICACION ****
set :erb, :escape_html => true

use OmniAuth::Builder do
  config = YAML.load_file 'config/config.yml'
  provider :google_oauth2, config['identifier'], config['secret']
end

enable :sessions
set :session_secret, '*&(^#234a)'
#***********************

get '/' do
  puts "inside get '/': #{params}"
  if (session[:email].to_s == '')
    @list = ShortenedUrl.all(:order => [ :id.asc ], :limit => 20, :username => "")
    # in SQL => SELECT * FROM "ShortenedUrl" WHERE username = '' ORDER BY "id" ASC
  else
    @list = ShortenedUrl.all(:username => session[:email], :order => [ :id.asc ], :limit => 20)
    # in SQL => SELECT * FROM "ShortenedUrl" WHERE username = 'session[:email]' ORDER BY "id" ASC
  end
  haml :index
end

post '/' do
  puts "inside post '/': #{params}"
  uri = URI::parse(params[:url])
  uriShort = URI::parse(params[:myurlshort])
  if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
    begin
      @short_url = ShortenedUrl.first_or_create(:url => params[:url], :myurl => params[:myurlshort], :username => session[:email])
    rescue Exception => e
      puts "EXCEPTION!!!!!!!!!!!!!!!!!!!"
      pp @short_url
      puts e.message
    end
  else
    logger.info "Error! <#{params[:url]}> is not a valid URL"
  end
  redirect '/'
end

get '/:shortened' do
  puts "inside get '/:shortened': #{params}"

  if (params[:myurlshort] == '')
    short_url = ShortenedUrl.first(:id => params[:shortened].to_i(Base))
  else
    short_url = ShortenedUrl.first(:myurl => params[:shortened])
  end

  # HTTP status codes that start with 3 (such as 301, 302) tell the
  # browser to go look for that resource in another location. This is
  # used in the case where a web page has moved to another location or
  # is no longer at the original location. The two most commonly used
  # redirection status codes are 301 Move Permanently and 302 Found.
  redirect short_url.url, 301
end

get '/auth/:name/callback' do
  session[:auth] = @auth = request.env['omniauth.auth']
  session[:name] = @auth['info'].name
  session[:image] = @auth['info'].image
  session[:url] = @auth['info'].urls.values[0]
  session[:email] = @auth['info'].email

  #flash[:notice] =
    #{}%Q{<div class="chuchu">Autenticado como #{@a...uth['info'].name}.</div>}
   #{}%Q{<div class="chuchu">Autenticado como #{@a...uth['info'].name}.</div>}

  # Añadir a la base de datos directamente, siempre y cuando no exista
  #if !User.first(:username => session[:email])
  #  u = User.create(:username => session[:email])
  #  u.save
  #end

  redirect '/'
end

get '/auth/failure' do
  #flash[:notice] =·
   # %Q{<div class="error-auth">Error: #{params[:message]}.</div>}
  redirect '/'
end

get '/logout/salir' do
  session.clear

  redirect '/'
end

error do haml :index end

