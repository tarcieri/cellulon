require 'cinch'
require 'celluloid'

# The colors, Duke! The colors!1!
module Tty extend self
  def escape(n); "\033[#{n}m" if STDOUT.tty? end
  def bold(n); escape "1;#{n}" end
  def blue; bold 34; end
  def white; bold 39; end
  def underline(n); escape "4;#{n}" end
  def red; underline 31; end
  def reset; escape 0; end
  def ohai(something)
    puts "#{Tty.blue}*** #{Tty.white}#{something}#{Tty.reset}" if STDOUT.tty?
  end
end

class Worker
  include Celluloid
  
  ROOT    = File.expand_path '../..', __FILE__
  TIMEOUT = 900
  HOOK    = /^![a-z][a-z0-9\-]*[a-z0-9]*/
      
  def handle_message(msg)
    p msg
    hook = msg.message[HOOK]
    return unless hook    

    args = msg.message.split(/\s+/)
    args.shift # remove the hook as an argument
    
    run hook, msg.user.nick, args do |response|
      msg.reply response
    end
  end
  
  def run(hook, user, args)
    script = File.join(ROOT, 'scripts', 'hooks', hook.sub(/^!/, ''))
    return unless File.executable?(script)
    
    Tty.ohai "Running #{hook} #{args.join(' ')}"
    
    Timeout.timeout TIMEOUT do
      Open3.popen2e({'CALLED_BY' => user}, script, *args) do |stdin, stdout|
        while line = stdout.gets
          line.force_encoding("UTF-8") if line.respond_to? :force_encoding
          line.strip!
          yield line
        end
      end
    end
  end
  
  alias_method :<<, :handle_message
end

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
