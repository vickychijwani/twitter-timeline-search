require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'models/tweet'

class Place
   include DataMapper::Resource
   
   property :id,                       String,     :required => true,   :length => 20,                      :index => true,   :key => true
   property :name,                     String,     :required => true,   :length => 500
   property :full_name,                String,     :required => true,   :length => 500
   property :place_type,               String,     :required => true,   :length => 20
   property :country,                  String,     :required => true,   :length => 200
   
   # relationships
   has n,                              :tweets
end
