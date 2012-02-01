module Rogue
  class World < Space
    attr_reader :children, :room, :corridor
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
          children.map { |c| c.split!(desired_width, desired_height) }.compact.any?
        end
      end
    end

    def generate_corridors!
      unless children.nil?
        children.map { |c| c.generate_corridors! }
        # Only gonna do the right thing if we have 2 children.
        children.permutation(2).each { |a, b| a.connect_to!(b) }
      end
    end

    def connect_to!(other_world)
      unless room.nil?
        adjoining_boundary = adjoining_boundary(other_world)

        case adjoining_boundary
        when :west, :east
          @corridor = Corridor.horizontal(room.wall(adjoining_boundary), wall(adjoining_boundary), adjoining_boundary)
        when :north, :south
          @corridor = Corridor.vertical(room.wall(adjoining_boundary), wall(adjoining_boundary), adjoining_boundary)
        end
      end
    end

    def adjoining_boundary(other_world)
      top_left, top_right, bottom_left, bottom_right = *boundaries
      other_top_left, other_top_right, other_bottom_left, other_bottom_right = *other_world.boundaries

      case
      when (wall(:west) == other_world.wall(:east))
        :west
      when (wall(:east) == other_world.wall(:west))
        :east
      when (wall(:north) == other_world.wall(:south))
        :north
      when (wall(:south) == other_world.wall(:north))
        :south
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
      pos = Spreader.new(((0+desired_height)..(height-desired_height)).to_a).get_weighted_random_item
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
      pos = Spreader.new(((0+desired_width)..(width-desired_width)).to_a).get_weighted_random_item
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

    def to_s(with_children = true)
      "<World: #{width}x#{height} at (#{x},#{y})#{with_children ? ((children || []).any? ? " containing:\n  #{@children.map{|c| c.to_s }.join(',')}": '') : ''}>"
    end
  end
end