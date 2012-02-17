module Rogue
  class ElRogue < Creature
    attr_reader :eye_strength

    def initialize(room, eye_strength)
      super(room)
      @eye_strength = eye_strength
    end
  end
end
