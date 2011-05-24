require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# require 'sinatra'
# require 'haml'
# require 'nokogiri'
# require 'dm-core'
# require 'dm-migrations'

require 'net/http'
require 'open-uri'
require 'models/tweet'
require 'twitter_functions'

include TwitterFunctions

DataMapper::setup(:default, (ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/tweets.db") )
# DataMapper.auto_migrate!
Tweet.auto_migrate! unless Tweet.storage_exists?
User.auto_migrate! unless User.storage_exists?
Place.auto_migrate! unless Place.storage_exists?
Geolocation.auto_migrate! unless Geolocation.storage_exists?

get '/' do
   haml :user
end

get '/loading' do
   user = params[:user]
   load_tweets(user)
   # redirect '/search'
end

get '/search' do
   @search_term = params[:search_term]
   @search_type = params[:search_type].to_i
   @users = params[:users]
   @tweets = search_tweets(@users, @search_type, @search_term) if @search_term && @search_term != ""
   haml :search
end
