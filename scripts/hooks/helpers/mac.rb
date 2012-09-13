# encoding: utf-8
require 'open3'
require 'uri'

module Helpers
  module Mac
    # Evaluate the given AppleScript string
    def run_applescript(script)
      lock(:applescript) do
        Open3.popen3("osascript") do |stdin, _|
          stdin << script
        end
      end
      nil
    end

    # 'ascript' is shorthand for AppleScript eval
    alias_method :ascript, :run_applescript
    
    # Open the given URL with Chrome on the TV
    def open_in_browser(url)
      uri = URI.parse(url)
      uri = URI.parse("http://#{url}") unless uri.is_a? URI::HTTP

      ascript <<-EOD
        tell application "Google Chrome"
          open location "#{url}"
        end tell
      EOD
    end
    
    # Say something on the teeve
    def say(*text)
      opts = text[-1].is_a?(Hash) ? text.pop : {}

      cmd = "say"
      if opts[:voice]
        if opts[:voice] =~ /[^\w ]/
          puts "Screw you hacker!"
          exit
        end
        cmd << " -v \"#{opts[:voice]}\""
      end

      lock(:say) { pipe_to_cmd text.join(' '), cmd }
    end
  end
end

include Helpers::Mac
