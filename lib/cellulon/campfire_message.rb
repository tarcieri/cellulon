module Cellulon
  class CampfireMessage
    attr_reader :type, :nickname, :body
    
    def initialize(room, type, nickname, body)
      @room, @type, @nickname, @body = room, type, nickname, body
    end
    
    def reply(message)
      @room.speak message
    end
  end
end