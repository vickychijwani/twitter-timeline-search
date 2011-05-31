require 'nokogiri'

module TwitterFunctions
   NUM_PAGES = 10 # number of pages to index
   
   def remove_user(user_name)
      if (user = User.get(user_name))
         Tweet.all(:user => user).destroy!
         user.destroy!
         return true
      else
         return false
      end
   end
   
   def search_tweets(users, search_type, search_term)
      if users == "0"
         users = User.all.map { |user| user = user.screen_name }
      else
         *users = users
      end
      
      case search_type
         when 0 then Tweet.all(Tweet.user.screen_name => users, :text.like => "%"+search_term+"%", :order => [ :created_at.desc ])
         when 1 then
            date_start, date_end = search_term.split(" to ").map { |s| s = s+"T00:00:00+00:00" }
            date_start, date_end = DateTime.parse(date_start), DateTime.parse(date_end)
            Tweet.all(Tweet.user.screen_name => users, :created_at.gt => date_start, :order => [ :created_at.desc ]) & Tweet.all(Tweet.user.screen_name => users, :created_at.lt => date_end, :order => [ :created_at.desc ])
         when 2 then Tweet.all(Tweet.user.screen_name => users, :retweets.gt => search_term.to_i, :order => [ :created_at.desc ])
         when 3 then Tweet.all(Tweet.user.screen_name => users, :in_reply_to_screen_name => search_term, :order => [ :created_at.desc ])
      end
   end

   def load_tweets(user_name)
      (1..NUM_PAGES).each do |i|
         puts "Page #{i}"
         
         url = "http://api.twitter.com/1/statuses/user_timeline.xml?page=#{i}&screen_name=#{user_name}"
         # url = "user_timeline.xml"
         begin
            timeline_xml_doc = Nokogiri::XML(open(url))
         rescue OpenURI::HTTPError => e
            puts e.message
            puts e.backtrace[-20..-1]
            puts "No such user."
            return false;
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
               user.save
               return true # if the current tweet exists, then return because all further tweets will also exist (tweets are sorted in descending order of time)
            end # end if Tweet.get(tweet_id).nil?
         end
         
         user.save
      end
      
      return true
   end # end load_tweets
   
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
   
   def parse_tweet
      self.gsub(/(http:\/\/\S+)/,'<a target="_blank" class="link" href="\1">\1</a>').gsub(/@(\w+)/,'<a target="_blank" class="tweet-mention" href="http://twitter.com/#!/\1"><span class="at">@</span><span class="at-mention">\1</span></a>').gsub(/#(\w+)/,'<a target="_blank" class="hashtag" href="http://twitter.com/#!/search?q=%23\1"><span class="hash">#</span><span class="tag">\1</span></a>')
   end
end

class Nokogiri::XML::Element
   def first(selector)
      self.at_css(selector).content
   end
end
