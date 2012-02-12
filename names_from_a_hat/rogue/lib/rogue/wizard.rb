module Rogue
  class Wizard < Creature
    attr_reader :handle

    def initialize(room, handle, details)
      super(room)
      @handle = handle
      @details = details
    end

    def name
      @details[:name]
    end

    def talk
      @details[:talk]
    end
  end
end