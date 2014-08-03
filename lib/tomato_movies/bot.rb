require 'rubygems'
require 'httparty'
require 'redis'
require 'time'

module TomatoMovies
  class Bot
    ROTTEN_TOMATOES_API_KEY = ENV['ROTTEN_TOMATOES_API_KEY']
    TWITTER_ACCESS_TOKEN = ENV['TWITTER_ACCESS_TOKEN']
    TWITTER_ACCESS_TOKEN_SECRET = ENV['TWITTER_ACCESS_TOKEN_SECRET']

    def run
      response = HTTParty.get("http://api.rottentomatoes.com/api/public/v1.0/lists/movies/opening.json?apikey=#{ROTTEN_TOMATOES_API_KEY}")
      movies = JSON(response.body)['movies']

      movies.each do |movie|
        release_date = Time.parse(movie['release_dates']['theater'])

        if today?(release_date) && !tweeted?(movie)
          if movie['ratings']['critics_rating'] == 'Certified Fresh'
            tweet "#{movie['title']} 🍅 #{movie['ratings']['critics_score']}%\n\n#{movie['links']['alternate']}"
          end
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
          config.consumer_key    = TWITTER_ACCESS_TOKEN
          config.consumer_secret = TWITTER_ACCESS_TOKEN_SECRET
        end

        @@client.update(text)
      else
        puts text
        puts '---'
      end
    end
  end
end
