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
    def open_with_chrome(url)
      uri = URI.parse(url)
  
      unless uri.is_a? URI::HTTP
        puts "What kind of a fucking URL is this crap? #{url}"
        exit 1
      end

      ascript <<-EOD
        tell application "Google Chrome"
          open location "#{url}"
        end tell
      EOD
    end
  end
end

include Helpers::Mac