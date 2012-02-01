module Rogue
  class Space
    attr_reader :width, :height, :x, :y
    def initialize(width, height, x, y)
      @width = width
      @height = height
      @x = x
      @y = y
    end

    def boundaries
      [
        # top left, top right
        [x, y], [(x + width - 1), y],
        # bottom left, bottom right
        [x, (y + (height - 1))], [(x + width - 1), (y + (height - 1))]
      ]
    end

    def wall(direction)
      top_left, top_right, bottom_left, bottom_right = *boundaries

      case direction
      when :east
        [top_right, bottom_right]
      when :west
        [top_left, bottom_left]
      when :north
        [top_left, top_right]
      when :south
        [bottom_left, bottom_right]
      end
    end
  end
end