require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'models/user'
require 'models/place'
require 'models/geolocation'

class Tweet
   include DataMapper::Resource
   
   property :id,                       String,        :required => true,   :index => true,   :length => 20,    :key => true
   
   property :created_at,               DateTime,      :required => true,   :index => true
   property :text,                     Text,          :required => true,   :index => true,   :length => 140,   :lazy => false
   property :source,                   String,        :required => true,                     :length => 200
   
   property :in_reply_to_status_id,    String,        :required => false
   property :in_reply_to_screen_name,  String,        :required => false,  :index => true
   
   property :retweets,                 Integer,       :required => true,   :index => true
   
   # relationships
   belongs_to                          :user,         :required => true
   belongs_to                          :place,        :required => false
   belongs_to                          :geolocation,  :required => false
end
