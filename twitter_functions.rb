require 'nokogiri'

module TwitterFunctions
   
   def search_tweets(users, search_type, search_term)
      tweets = []
      
      if users == "0"
         users = User.all.map { |user| user = user.id }
      else
         *users = users.to_i
      end
      
      case search_type
         when 0 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.id) && tweet.text.downcase.include?(search_term) }
         when 1 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.id) && search_term == tweet.created_at.strftime("20%y/%m/%d") }
         when 2 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.id) && search_term > tweet.created_at.strftime("20%y/%m/%d") }
         when 3 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.id) && search_term < tweet.created_at.strftime("20%y/%m/%d") }
         when 4 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.id) && tweet.retweets > search_term.to_i }
         when 5 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.id) && User.get(tweet.in_reply_to_user_id) == search_term.to_i }
      end
      tweets
   end

   def load_tweets(user)
      (1..1).each do |i|
         puts "Page #{i}"
         
         url = "http://api.twitter.com/1/statuses/user_timeline.xml?page=#{i}&screen_name=#{user}"
         begin
            timeline_xml_doc = Nokogiri::XML(open(url))
         rescue OpenURI::HTTPError
            puts "No such user."
            redirect '/?user_exists=false'
         end
         timeline_xml_doc = Nokogiri::XML(open(url))
         
         statuses = timeline_xml_doc.css('statuses status')
         
         user_element = statuses.at_css('status user')
         time_arr = user_element.first('created_at').split(" ")
         hour, min, sec = time_arr[3].scan(/\d\d/).map(&:to_i)
         created_at = Time.mktime(time_arr[5].to_i, time_arr[1].downcase!, time_arr[2].to_i, hour, min, sec)
         
         user = User.new(
            :id                              => user_element.first('id').to_i,
            :name                            => user_element.first('name'),
            :screen_name                     => user_element.first('screen_name'),
            :location                        => user_element.first('location'),
            :description                     => user_element.first('description'),
            :profile_image_url               => user_element.first('profile_image_url'),
            :url                             => user_element.first('url'),
            :protected                       => user_element.first('protected').to_b,
            :followers_count                 => user_element.first('followers_count').to_i,
            :profile_background_color        => user_element.first('profile_background_color'),
            :profile_text_color              => user_element.first('profile_text_color'),
            :profile_link_color              => user_element.first('profile_link_color'),
            :profile_sidebar_fill_color      => user_element.first('profile_sidebar_fill_color'),
            :profile_sidebar_border_color    => user_element.first('profile_sidebar_border_color'),
            :friends_count                   => user_element.first('friends_count').to_i,
            :created_at                      => created_at,
            :favourites_count                => user_element.first('favourites_count').to_i,
            :utc_offset                      => user_element.first('utc_offset').to_i,
            :time_zone                       => user_element.first('time_zone'),
            :profile_background_image_url    => user_element.first('profile_background_image_url'),
            :profile_background_tile         => user_element.first('profile_background_tile').to_b,
            :profile_use_background_image    => user_element.first('profile_use_background_image').to_b,
            :notifications                   => user_element.first('notifications').to_b,
            :geo_enabled                     => user_element.first('geo_enabled').to_b,
            :verified                        => user_element.first('verified').to_b,
            :following                       => user_element.first('following').to_b,
            :statuses_count                  => user_element.first('statuses_count').to_i,
            :lang                            => user_element.first('lang'),
            :contributors_enabled            => user_element.first('contributors_enabled').to_b,
            :follow_request_sent             => user_element.first('follow_request_sent').to_b,
            :listed_count                    => user_element.first('listed_count').to_i,
            :show_all_inline_media           => user_element.first('show_all_inline_media').to_b,
            :default_profile                 => user_element.first('default_profile').to_b,
            :default_profile_image           => user_element.first('default_profile_image').to_b,
            :is_translator                   => user_element.first('is_translator').to_b
         )
         
         statuses.each do |status|
            
            tweet_id = status.first('id').to_i
            
            if Tweet.get(tweet_id).nil?
               time_arr = status.first('created_at').split(" ")
               hour, min, sec = time_arr[3].scan(/\d\d/).map(&:to_i)
               created_at = Time.mktime(time_arr[5].to_i, time_arr[1].downcase!, time_arr[2].to_i, hour, min, sec)
               
               geo_lat, geo_long = status.first('geo').split(" ") if status.first('geo')
               coord_lat, coord_long = status.first('coordinates').split(" ") if status.first('coordinates')            
               
               tweet = Tweet.new(
                  :id                              => status.first('id').to_i,
                  :created_at                      => created_at,
                  :text                            => status.first('text'),
                  :source                          => status.first('source'),
                  :truncated                       => status.first('truncated').to_b,
                  :favorited                       => status.first('favorited').to_b,
                  :in_reply_to_status_id           => ( status.first('in_reply_to_status_id').to_i if status.first('in_reply_to_status_id') != "" ),
                  :in_reply_to_user_id             => ( status.first('in_reply_to_user_id').to_i if status.first('in_reply_to_user_id') != "" ),
                  :retweets                        => status.first('retweet_count').to_i,
                  :geo_lat                         => geo_lat,
                  :geo_long                        => geo_long,
                  :coord_lat                       => coord_lat,
                  :coord_long                      => coord_long
               )
               
               user.tweets << tweet
               
               place_element = status.at_css('place')
               
               if place_element.content != ""
                  place = Place.get(place_element.first('id'))
                  if place.nil?
                     place = Place.new(
                        :id            => place_element.first('id'),
                        :name          => place_element.first('name'),
                        :full_name     => place_element.first('full_name'),
                        :place_type    => place_element.first('place_type'),
                        :country       => place_element.first('country')
                        )
                  end
                  place.tweets << tweet
                  place.save
               end
               
            # else
               # return   # return because if the current tweet exists in the db, then we can assume that all previous tweets do too
            end
         end
         
         user.save
         sleep(2)
      end
   end
   
end

class String
   def to_b
      if self.downcase == "true"
         true
      elsif self.nil? || self == ""
         nil
      else
         false
      end
   end
end

class Nokogiri::XML::Element
   def first(selector)
      self.at_css(selector).content
   end
end
