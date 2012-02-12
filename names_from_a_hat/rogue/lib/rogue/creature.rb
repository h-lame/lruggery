module Rogue
  class Creature
    attr_reader :x, :y

    def initialize(room)
      north_wall = room.wall_positions(:north)
      @x = north_wall[north_wall.size / 2].first
      west_wall = room.wall_positions(:west)
      @y = west_wall[west_wall.size / 2].last
    end

    def move_to(x, y)
      @x = x
      @y = y
    end
  end
end
