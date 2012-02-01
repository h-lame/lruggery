module Rogue
  class Generator
    attr_reader :width, :height, :desired_room_width, :desired_room_height

    def initialize(width, height, desired_room_width, desired_room_height)
      @width = width
      @height = height
      @desired_room_height = desired_room_height
      @desired_room_width = desired_room_width
    end

    def generate!(worlds = 10)
      w = World.new(width, height, 0, 0)
      while w.splittable?(desired_room_width + 2, desired_room_height + 2) && w.world_count < worlds
        w.split!(desired_room_width + 2, desired_room_height + 2)
      end
      w.generate_rooms!(desired_room_width, desired_room_height)
      w.generate_corridors!
      w
    end
  end
end
