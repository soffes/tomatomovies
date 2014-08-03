require 'rubygems'
require 'redis'

module TomatoMovies
  ROTTEN_TOMATOES_API_KEY = ENV['ROTTEN_TOMATOES_API_KEY']
  TWITTER_ACCESS_TOKEN = ENV['TWITTER_ACCESS_TOKEN']
  TWITTER_ACCESS_TOKEN_SECRET = ENV['TWITTER_ACCESS_TOKEN_SECRET']

  module_function

  def redis
    @@redis ||= begin
      uri = URI.parse(ENV['REDISTOGO_URL'] || 'redis://localhost:6379')
      Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end
  end
end

require 'tomato_movies/bot'
require 'tomato_movies/application'
