# encoding: utf-8

require 'open3'

module Helpers
  HOOK_PATTERN = /^[a-z][a-z0-9\-]*[a-z0-9]*$/
  
  module Core
    # Usage info
    def usage(string)
      if ARGV[0] == 'help'
        puts string
        exit 1
      end
    end
    
    # Obtain all arguments as a single string
    def input_string
      return nil unless ARGV[0]
      @input ||= ARGV[0..-1].join(' ')
    end
    alias_method :input, :input_string
    
    # Who was this script called by?
    def called_by
      ENV['CALLED_BY']
    end
    alias_method :who, :called_by
    
    # Paste a string into the channel
    def paste(string)
      puts "###paste: #{string.dump}"
    end
    
    # Execute a command and dump its results to the channel
    def sh(command, strip = true)
      result, _ = Open3.capture2e(command)
      
      if strip
        result.gsub!(/\033\[.*?m/, '')
        result.strip!
      end
      
      paste result
    end
    
    # Obtain an exclusive cross-hook clock
    def lock(name)
      dir = File.expand_path('../../../../tmp', __FILE__)

      File.open(File.join(dir, name.to_s), "w") do |file|
        file.flock(File::LOCK_EX)
        yield
      end
    end
    
    # Pipe a buffer to the given command
    def pipe_to_cmd(input, *cmd)
      Open3.popen2(*cmd) do |stdin, stdout|
        stdin << input
        stdin.close
        stdout.read
      end
    end
  end
end

include Helpers::Core