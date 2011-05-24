require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'models/user'
require 'models/place'

class Tweet
   include DataMapper::Resource
   
   property :id,                       Integer,    :required => true,   :index => true,                     :key => true
   
   property :created_at,               DateTime,   :required => true,   :index => true
   property :text,                     Text,       :required => true,   :index => true,   :length => 140,   :lazy => false
   property :source,                   String,     :required => true,                     :length => 200
   
   property :truncated,                Boolean,    :required => true,                                       :default => false
   property :favorited,                Boolean,    :required => true,                                       :default => false
   
   property :in_reply_to_status_id,    Integer,    :required => false
   property :in_reply_to_user_id,      Integer,    :required => false,  :index => true
   
   property :retweets,                 Integer,    :required => true,   :index => true
   
   property :geo_lat,                  Decimal,    :required => false,                                      :scale => 0, :precision => 10
   property :geo_long,                 Decimal,    :required => false,                                      :scale => 0, :precision => 10
   
   property :coord_lat,                Decimal,    :required => false,                                      :scale => 0, :precision => 10
   property :coord_long,               Decimal,    :required => false,                                      :scale => 0, :precision => 10
   
   # relationships
   belongs_to                          :user,      :required => true
   belongs_to                          :place,     :required => false
end
