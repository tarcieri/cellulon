require 'cinch'
require 'tinder'
require 'celluloid'
require 'cellulon/version'

require 'cellulon/campfire_message'
require 'cellulon/worker'

module Cellulon
  # Start the bot
  def self.run
    worker_pool = Cellulon::Worker.pool

    campfire = Tinder::Campfire.new 'hungrymachine', :token => ENV['CAMPFIRE_TOKEN']
    room = campfire.find_room_by_name('Test')
    room.listen do |event|
      type = event['type'].scan(/[A-Z][a-z0-9]+/).map(&:downcase).join('_').to_sym
      nick = event['user'] ? event['user']['name'].force_encoding('UTF-8') : nil
      body = event['body'].force_encoding('UTF-8') if event['body']

      worker_pool << CampfireMessage.new(room, type, nick, body)
    end 
    
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