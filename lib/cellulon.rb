require 'cinch'
require 'tinder'
require 'celluloid'

require 'cellulon/version'
require 'cellulon/worker'

require 'cellulon/campfire/client'
require 'cellulon/campfire/message'

module Cellulon
  # Start the bot
  def self.run
    Celluloid::Actor[:cellulon_pool] = Cellulon::Worker.pool

    client = Campfire::Client.new('hungrymachine', :token => ENV['CAMPFIRE_TOKEN'])
    client.join(ENV['CHANNEL'])
    
    # TODO: configuration for IRC vs Campfire
    # bot = Cinch::Bot.new do
    #   configure do |c|
    #     c.nick = "cellulon"
    #     c.server = "irc.freenode.net"
    #     c.channels = ["#celluloid"]
    #   end
    # 
    #   on(:message) { |msg| pool.get! { |worker| worker << msg } }
    # end
    # 
    # bot.start
  end
end
