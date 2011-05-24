require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'models/tweet'

class User
   include DataMapper::Resource
   
   property :screen_name,                       String,     :required => true,      :length => 200,   :index => true,      :key => true
   property :name,                              String,     :required => true,      :length => 200
   property :location,                          String,     :required => false,     :length => 200
   property :description,                       Text,       :required => false,     :length => 160
   property :profile_image_url,                 Text,       :required => true,      :length => 1000
   property :url,                               Text,       :required => false,     :length => 1000
   property :followers_count,                   Integer,    :required => true,                        :default => 0
   property :friends_count,                     Integer,    :required => true,                        :default => 0
   property :statuses_count,                    Integer,    :required => true
   property :lang,                              String,     :required => true,                        :default => "en"
   
   # relationships
   has n,                                       :tweets
end
