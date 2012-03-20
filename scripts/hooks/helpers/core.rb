module Helpers
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
      @input ||= ARGV[0..-1].join(' ') if ARGV[0]
    end
    
    # Who was this script called by?
    def called_by
      ENV['CALLED_BY']
    end
    alias_method :who, :called_by
  end
end

include Helpers::Core