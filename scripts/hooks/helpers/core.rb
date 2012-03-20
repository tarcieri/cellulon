# encoding: utf-8

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
    def input
      return nil unless ARGV[0]
      @input ||= ARGV[0..-1].join(' ')
    end
    
    # Who was this script called by?
    def called_by
      ENV['CALLED_BY']
    end
    alias_method :who, :called_by
  end
end

include Helpers::Core