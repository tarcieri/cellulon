require 'cinch'
require 'celluloid'

require 'cellulon/version'
require 'cellulon/worker'

module Cellulon
  # Start the bot
  def self.run
    pool = Celluloid::Pool.new Worker, :max_size => 10

    bot = Cinch::Bot.new do
      configure do |c|
        c.nick = "cellulon"
        c.server = "irc.freenode.net"
        c.channels = ["#celluloid"]
      end

      on(:message) { |msg| pool.get! { |worker| worker << msg } }
    end

    bot.start
  end
end
