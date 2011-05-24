require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'models/tweet'

class Geolocation
   include DataMapper::Resource
   
   property :latitude,                  Decimal,       :required => true,   :key => true,  :scale => 0,   :precision => 10
   property :longitude,                 Decimal,       :required => true,   :key => true,  :scale => 0,   :precision => 10
   
   # relationships
   has n,                              :tweets
end
