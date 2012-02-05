module Rogue
  class Player
    attr_reader :x, :y

    def initialize(room)
      north_wall = room.wall_positions(:north)
      @x = north_wall[north_wall.size / 2].first
      west_wall = room.wall_positions(:west)
      @y = west_wall[west_wall.size / 2].last
    end

    def move(key)
      case key
      when 'w'
        @y -= 1
      when 's'
        @y += 1
      when 'a'
        @x -= 1
      when 'd'
        @x += 1
      end
    end
  end
end
