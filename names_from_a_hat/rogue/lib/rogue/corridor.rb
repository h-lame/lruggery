module Rogue
  class Corridor
    attr_accessor :start, :length, :direction
    def self.horizontal(wall, plane, direction)
      raise ArgumentError, "can't go horizontally #{direction}" unless [:east, :west].include?(direction)
      w_top, w_bottom = *wall
      p_top, p_bottom = *plane

      start = [w_top.first, Spreader.new((w_top.last..w_bottom.last).to_a).item(:middle)]
      # wall is on plane already
      if w_top.first == p_top.first
        new(start, 1, direction)
      else
        length = (w_top.first - p_top.first).abs
        new(start, length + 1, direction)
      end
    end

    def self.vertical(wall, plane, direction)
      raise ArgumentError, "can't go vertically #{direction}" unless [:north, :south].include?(direction)
      w_left, w_right = *wall
      p_left, p_right = *plane

      start = [Spreader.new((w_left.first..w_right.first).to_a).item(:middle), w_left.last]
      # wall is on plane already
      if w_left.last == p_left.last
        new(start, 1, direction)
      else
        length = (w_left.last - p_left.last).abs
        new(start, length + 1, direction)
      end
    end

    def initialize(start, length, direction)
      @start = start
      @length = length
      @direction = direction
    end

    def positions
      length.times.map do |i|
        case direction
        when :north
          [@start.first, @start.last - i]
        when :east
          [@start.first + i, @start.last]
        when :south
          [@start.first, @start.last + i]
        when :west
          [@start.first - i, @start.last]
        end
      end
    end
  end
end
