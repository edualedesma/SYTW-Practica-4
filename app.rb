#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require 'uri'
require 'pp'
#require 'socket'
require 'data_mapper'

require './auth.rb'

# Configuracion en local
configure :development, :test do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 
                             "sqlite3://#{Dir.pwd}/my_shortened_urls.db" )
end

# Configuracion para Heroku
configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

#DataMapper.setup( :default, ENV['DATABASE_URL'] || 
#                            "sqlite3://#{Dir.pwd}/my_shortened_urls.db" )
DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 

require_relative 'model'

DataMapper.finalize

#DataMapper.auto_migrate!
DataMapper.auto_upgrade!

Base = 36

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
  uriShort = URI::parse(params[:myurlshort].to_s.strip.sub(' ', '_'))
  if uri.is_a? URI::HTTP or uri.is_a? URI::HTTPS then
    begin
      @short_url = ShortenedUrl.first_or_create(:url => params[:url], :myurl => params[:myurlshort], :username => session[:email].to_s)
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

  if (params[:shortened] == '' || params[:shortened].nil?)
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

get '/logout/salir' do
  session.clear

  redirect '/'
end

error do haml :index end

