module Rogue
  class Room < Space
    def self.generate!(desired_width, desired_height, within_world)
      top_left, top_right, bottom_left, bottom_right = *within_world.boundaries

      width = Spreader.new((desired_width..within_world.width).to_a).item(:first)
      height = Spreader.new((desired_height..within_world.height).to_a).item(:first)

      if width && height
        x = Spreader.new((0..(within_world.width - width)).to_a).item(:middle)
        y = Spreader.new((0..(within_world.height - height)).to_a).item(:middle)
        if x && y
          new(width, height, within_world.x + x, within_world.y + y)
        else
          nil
        end
      else
        nil
      end
    end
    
    def slice_horizontally
      wall_positions(:north).map {|pos| pos.first}.uniq
    end

    def slice_vertically
      wall_positions(:west).map {|pos| pos.last}.uniq
    end

    def furthest(direction, position)
      w = wall_positions(direction)
      case direction
      when :east, :west
        w.detect { |p| p.last == position }
      when :north, :south
        w.detect { |p| p.first == position }
      end
    end

    def to_s
      "<Room: #{width}x#{height} at (#{x},#{y})>"
    end
  end
end
