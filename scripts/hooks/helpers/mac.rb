# encoding: utf-8
require 'open3'

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
  end
end

include Helpers::Mac