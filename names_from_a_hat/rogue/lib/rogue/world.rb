module Rogue
  class World < Space
    attr_reader :children, :room
    def world_count
      if children.nil?
        1
      else
        children.map { |c| c.world_count }.inject(:+) || 1
      end
    end

    def split!(desired_width, desired_height)
      if splittable?(desired_height, desired_height)
        if children.nil?
          direction = possible_directions(desired_width, desired_height).sample
          send(:"split_#{direction}ly", desired_width, desired_height) if direction
        else
          children.any? { |c| c.split!(desired_width, desired_height) }
        end
      end
    end
  
    def generate_rooms!(desired_width, desired_height)
      if children.nil?
        @room = Room.generate!(desired_width, desired_height, self)
      else
        children.each { |c| c.generate_rooms!(desired_width, desired_height) }
      end
    end

    def splittable?(desired_width, desired_height)
      if children.nil?
        possible_directions(desired_width, desired_height).any?
      else
        children.any? { |c| c.splittable?(desired_width, desired_height) }
      end
    end

    def split_horizontally(desired_width, desired_height)
      pos = ((0+desired_height)..(height-desired_height)).to_a.sample
      @children =
        if pos
          [
            World.new(width, pos, x, y),
            World.new(width, (height - pos + 1), x, (y + pos - 1))
          ]
        else
          nil
        end
    end
  
    def split_vertically(desired_width, desired_height)
      pos = ((0+desired_width)..(width-desired_width)).to_a.sample
      @children =
        if pos
          [
            World.new(pos, height, x, y),
            World.new((width - pos + 1), height, (x + pos - 1), y)
          ]
        else
          nil
        end
    end
  
    def possible_directions(desired_width, desired_height)
      options = []
      options << :horizontal if (desired_height * 2) <= height
      options << :vertical if (desired_width * 2) <= width
      options
    end
  
    def to_s
      "<World: #{width}x#{height} at (#{x},#{y})#{(children || []).any? ? " containing:\n  #{@children.map{|c| c.to_s }.join(',')}": ''}>"
    end
  end
end
