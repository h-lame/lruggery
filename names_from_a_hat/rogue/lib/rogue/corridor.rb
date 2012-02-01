module Rogue
  class Corridor
    attr_accessor :start, :length, :direction
    def self.horizontal(wall, plane, direction)
      raise ArgumentError, "can't go horizontally #{direction}" unless [:east, :west].include?(direction)
      w_top, w_bottom = *wall
      p_top, p_bottom = *plane

      start = [Spreader.new((w_top.first..w_bottom.first).to_a).get_weighted_random_item, w_top.last]
      # wall is on plane already
      if w_top.last == p_top.last || w_bottom.last == p_bottom.last
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

      start = [w_left.first, Spreader.new((w_left.last..w_right.last).to_a).get_weighted_random_item]
      # wall is on plane already
      if w_left.first == p_left.first || w_right.first == p_right.first
        new(start, 1, direction)
      else
        length = (w_left.last - p_left.last).abs
        new(start, length + 1, direction)
      end
    end

    def initialize(start, length, direction)
      puts "New #{direction} wall starting at (#{start.first},#{start.last}) for #{length} places"
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
