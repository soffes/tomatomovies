require 'rubygems'
require 'sinatra'

module TomatoMovies
  class Application < Sinatra::Application
    get '/' do
      redirect 'https://twitter.com/tomatomovies'
    end
  end
end
