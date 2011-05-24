require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'models/tweet'

class User
   include DataMapper::Resource
   
   property :id,                                Integer,    :required => true,                        :index => true,      :key => true
   property :name,                              String,     :required => true,      :length => 200
   property :screen_name,                       String,     :required => true,      :length => 200
   property :location,                          String,     :required => false,     :length => 200
   property :description,                       Text,       :required => false,     :length => 160
   property :profile_image_url,                 Text,       :required => true,      :length => 1000
   property :url,                               Text,       :required => false,     :length => 1000
   property :protected,                         Boolean,    :required => true,                        :default => false
   property :followers_count,                   Integer,    :required => true,                        :default => 0
   property :profile_background_color,          String,     :required => true,      :length => 6
   property :profile_text_color,                String,     :required => true,      :length => 6
   property :profile_link_color,                String,     :required => true,      :length => 6
   property :profile_sidebar_fill_color,        String,     :required => true,      :length => 6
   property :profile_sidebar_border_color,      String,     :required => true,      :length => 6
   property :friends_count,                     Integer,    :required => true,                        :default => 0
   property :created_at,                        DateTime,   :required => true
   property :favourites_count,                  Integer,    :required => true,                        :default => 0
   property :utc_offset,                        Integer,    :required => false
   property :time_zone,                         String,     :required => false,     :length => 100
   property :profile_background_image_url,      Text,       :required => true,      :length => 1000
   property :profile_background_tile,           Boolean,    :required => true,                        :default => false
   property :profile_use_background_image,      Boolean,    :required => true,                        :default => true
   property :notifications,                     Boolean,    :required => false
   property :geo_enabled,                       Boolean,    :required => true,                        :default => false
   property :verified,                          Boolean,    :required => true,                        :default => false
   property :following,                         Boolean,    :required => false
   property :statuses_count,                    Integer,    :required => true
   property :lang,                              String,     :required => true,                        :default => "en"
   property :contributors_enabled,              Boolean,    :required => true,                        :default => false
   property :follow_request_sent,               Boolean,    :required => false
   property :listed_count,                      Integer,    :required => true,                        :default => 0
   property :show_all_inline_media,             Boolean,    :required => true
   property :default_profile,                   Boolean,    :required => true,                        :default => true
   property :default_profile_image,             Boolean,    :required => true,                        :default => true
   property :is_translator,                     Boolean,    :required => true,                        :default => false
   
   # relationships
   has n,                                       :tweets
end
