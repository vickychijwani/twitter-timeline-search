require 'nokogiri'

module TwitterFunctions
   
   def search_tweets(users, search_type, search_term)
      tweets = []
      
      if users == "0"
         users = User.all.map { |user| user = user.screen_name }
      else
         *users = users
      end
      
      case search_type
         when 0 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.screen_name) && tweet.text.downcase.include?(search_term) }
         when 1 then
            date_start, date_end = search_term.split(" to ")
            tweets = Tweet.all.find_all { |tweet|
               users.include?(tweet.user.screen_name) && tweet.created_at.strftime("20%y/%m/%d") >= date_start && tweet.created_at.strftime("20%y/%m/%d") <= date_end
            }
         when 2 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.screen_name) && tweet.retweets > search_term.to_i }
         when 3 then tweets = Tweet.all.find_all { |tweet| users.include?(tweet.user.screen_name) && tweet.in_reply_to_screen_name == search_term }
      end
   end

   def load_tweets(user_name)
      (1..10).each do |i|
         puts "Page #{i}"
         
         url = "http://api.twitter.com/1/statuses/user_timeline.xml?page=#{i}&screen_name=#{user_name}"
         # url = "user_timeline.xml"
         begin
            timeline_xml_doc = Nokogiri::XML(open(url))
         rescue OpenURI::HTTPError => e
            puts "URL: "+url
            puts e.message
            puts e.backtrace
            puts "No such user."
            redirect '/?user_exists=false'
         end
         timeline_xml_doc = Nokogiri::XML(open(url))
         
         statuses = timeline_xml_doc.css('statuses status')
         
         user_element = statuses.at_css('status user')
         screen_name = user_element.first('screen_name')
         time_arr = user_element.first('created_at').split(" ")
         hour, min, sec = time_arr[3].scan(/\d\d/).map(&:to_i)
         created_at = Time.mktime(time_arr[5].to_i, time_arr[1].downcase!, time_arr[2].to_i, hour, min, sec)
         
         user = User.get(screen_name)
         if user.nil?
            user = User.new(
               :screen_name         => screen_name,
               :name                => user_element.first('name'),
               :location            => user_element.first('location'),
               :description         => user_element.first('description'),
               :profile_image_url   => user_element.first('profile_image_url'),
               :url                 => user_element.first('url'),
               :followers_count     => user_element.first('followers_count').to_i,
               :friends_count       => user_element.first('friends_count').to_i,
               :statuses_count      => user_element.first('statuses_count').to_i,
               :lang                => user_element.first('lang')
            )
         end
         
         statuses.each do |status|
            
            tweet_id = status.first('id')
            
            if Tweet.get(tweet_id).nil?
               time_arr = status.first('created_at').split(" ")
               hour, min, sec = time_arr[3].scan(/\d\d/).map(&:to_i)
               created_at = Time.mktime(time_arr[5].to_i, time_arr[1].downcase!, time_arr[2].to_i, hour, min, sec)
               
               tweet = Tweet.new(
                  :id                       => status.first('id'),
                  :created_at               => created_at,
                  :text                     => status.first('text'),
                  :source                   => status.first('source'),
                  :truncated                => status.first('truncated').to_b,
                  :favorited                => status.first('favorited').to_b,
                  :in_reply_to_status_id    => ( status.first('in_reply_to_status_id') if status.first('in_reply_to_status_id') != "" ),
                  :in_reply_to_screen_name  => ( status.first('in_reply_to_screen_name') if status.first('in_reply_to_screen_name') != "" ),
                  :retweets                 => status.first('retweet_count').to_i
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
               
               geo_element = status.at_css('geo')
               if geo_element.content != ""
                  latitude, longitude = geo_element.content.split(" ")
                  geolocation = Geolocation.get(latitude, longitude)
                  if geolocation.nil?
                     geolocation = Geolocation.new(
                        :latitude   => latitude,
                        :longitude  => longitude
                     )
                  end
                  geolocation.tweets << tweet
                  geolocation.save
               end
            
            else
               return # if the current tweet exists, then return because all further tweets will also exist (tweets are sorted in descending order of time)
            end # end if Tweet.get(tweet_id).nil?
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
