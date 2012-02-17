module Rogue
  class Wizard < Creature
    attr_reader :handle

    def initialize(room, handle, details)
      super(room)
      @handle = handle
      @details = details
      @defeated = false
    end

    def name
      @details['name']
    end

    def talk
      @details['talk']
    end

    def defeated?
      @defeated
    end

    def defeat!
      @defeated = true
    end
  end
end