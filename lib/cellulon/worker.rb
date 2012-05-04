module Cellulon
  # Workers run hooks inside of a thread pool
  class Worker
    include Celluloid::Worker
  
    ROOT    = File.expand_path '../../..', __FILE__
    TIMEOUT = 900
    HOOK    = /^![a-z][a-z0-9\-]*[a-z0-9]*/
      
    def handle_message(msg)
      puts "[#{msg.type}] <#{msg.nickname}> #{msg.body}"
      
      hook = msg.body[HOOK] if msg.body
      return unless hook    

      args = msg.body.split(/\s+/)
      args.shift # remove the hook as an argument
    
      run hook, msg.nickname, args do |response|
        msg.reply response
      end
    end
  
    def run(hook, user, args)
      script = File.join(ROOT, 'scripts', 'hooks', hook.sub(/^!/, ''))
      return unless File.executable?(script)
    
      STDERR.puts "Running #{hook} #{args.join(' ')}"
    
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
end