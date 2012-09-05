require 'time'

module Cellulon
  module Campfire
    class Client
      include Celluloid
      
      def initialize(subdomain, options = {})
        @campfire = Tinder::Campfire.new subdomain, options
      end
            
      def join(room_name)
        room = @campfire.find_room_by_name(room_name)
        room.listen do |event|
          type = event['type'].scan(/[A-Z][a-z0-9]+/).map(&:downcase).join('_').to_sym
          nick = event['user'] ? event['user']['name'].force_encoding('UTF-8') : nil
          
          if type == :timestamp_message
            body = event['created_at'].rfc2822
          elsif event['body']
            body = event['body'].force_encoding('UTF-8')
          end

          Actor[:cellulon_pool] << Campfire::Message.new(room, type, nick, body)
        end 
      end
    end
  end
end