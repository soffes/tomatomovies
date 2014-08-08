require 'rubygems'
require 'httparty'
require 'redis'
require 'twitter'
require 'time'

module TomatoMovies
  class Bot
    ROTTEN_TOMATOES_API_KEY = ENV['ROTTEN_TOMATOES_API_KEY']
    TWITTER_CONSUMER_KEY = ENV['TWITTER_CONSUMER_KEY']
    TWITTER_CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET']
    TWITTER_ACCESS_TOKEN = ENV['TWITTER_ACCESS_TOKEN']
    TWITTER_ACCESS_TOKEN_SECRET = ENV['TWITTER_ACCESS_TOKEN_SECRET']

    def run
      response = HTTParty.get("http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json?apikey=#{ROTTEN_TOMATOES_API_KEY}")
      movies = JSON(response.body)['movies']

      movies.each do |movie|
        release_date = Time.parse(movie['release_dates']['theater'])

        # Skip movies without an MPAA rating since it's probably something no one cares about
        next if movie['mpaa_rating'] == 'Unrated'

        # Skip the movie if it did't open today
        next unless today?(release_date)

        # Skip it if we've already tweeted it
        next if tweeted?(movie)

        # Only tweet good movies
        rating = movie['ratings']['critics_rating']
        if rating == 'Certified Fresh' || rating == 'Fresh'
          tweet "#{movie['title']} 🍅 #{movie['ratings']['critics_score']}%\n\n#{movie['links']['alternate']}"
        end
      end
    end

    private

    def today?(time)
      today = Time.new
      time.day == today.day && time.month == today.month && time.year == today.year
    end

    def tweeted?(movie)
      TomatoMovies.redis[movie['id'].to_s]
    end

    def tweet(text)
      if ENV['RACK_ENV'] == 'production'
        @@client ||= Twitter::REST::Client.new do |config|
          config.consumer_key = TWITTER_CONSUMER_KEY
          config.consumer_secret = TWITTER_CONSUMER_SECRET
          config.access_token = TWITTER_ACCESS_TOKEN
          config.access_token_secret = TWITTER_ACCESS_TOKEN_SECRET
        end

        @@client.update(text)
      else
        puts text
        puts '---'
      end
    end
  end
end
