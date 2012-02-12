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

    def wall_positions(direction)
      w = wall(direction)
      case direction
      when :east, :west
        (w.first.last..w.last.last).map {|y| [w.first.first, y]}
      when :north, :south
        (w.first.first..w.last.first).map {|x| [x, w.first.last]}
      end
    end

    def self.move(x,y, direction)
      case direction
      when :north
        [x, y -= 1]
      when :south
        [x, y += 1]
      when :west
        [x -= 1, y]
      when :east
        [x += 1, y]
      end
    end

    def self.point_on_line(x,y, p1, p2)
      a = -(p2.last - p1.last)
      b = p2.first - p1.first
      c = -(a * p1.first + b * p1.last)

      d = (a * x) + (b * y) + c
    end

    def is_in?(x,y)
      n_side = Space.point_on_line(x,y, *wall(:north))
      e_side = Space.point_on_line(x,y, *wall(:east))
      s_side = Space.point_on_line(x,y, *wall(:south).reverse)
      w_side = Space.point_on_line(x,y, *wall(:west).reverse)

      (n_side >= 0) && (e_side >= 0) && (s_side >= 0) && (w_side >= 0)
    end
  end
end