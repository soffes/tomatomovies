require 'rubygems'
require 'sinatra'

module TomatoMovies
  class Application < Sinatra::Application
    get '/' do
      'hi'
    end
  end
end
