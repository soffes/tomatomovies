require 'rubygems'

$LOAD_PATH.unshift 'lib'
require 'tomato_movies'

namespace :bot do
  desc 'Run the bot'
  task :run do
    bot = TomatoMovies::Bot.new
    bot.run
  end
end
