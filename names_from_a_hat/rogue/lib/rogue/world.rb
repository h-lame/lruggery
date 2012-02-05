module Rogue
  class World < Space
    attr_reader :children, :room
    attr_accessor :corridor
    def world_count
      if children.nil?
        1
      else
        children.map { |c| c.world_count }.inject(:+) || 1
      end
    end

    def rooms
      r = []
      r << @room
      children.each { |c| r += c.rooms } if children
      r.flatten.compact
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
        children.first.connect_to!(children.last)
      end
    end

    def connect_to!(other_world)
      adjoining_boundary = adjoining_boundary(other_world)

      @corridor =
        case adjoining_boundary
        when :west
          Corridor.horizontal(other_world, self)
        when :east
          Corridor.horizontal(self, other_world)
        when :north
          Corridor.vertical(other_world, self)
        when :south
          Corridor.vertical(self, other_world)
        end
      other_world.corridor = @corridor
    end

    def slice_horizontally
      slice = []
      if room
        slice += room.slice_horizontally
      end
      if corridor
        slice += corridor.slice_horizontally
      end
      if children
        children.each {|c| slice += c.slice_horizontally }
      end
      slice.uniq
    end

    def slice_vertically
      slice = []
      if room
        slice += room.slice_vertically
      end
      if corridor
        slice += corridor.slice_vertically
      end
      if children
        children.each {|c| slice += c.slice_vertically }
      end
      slice.uniq
    end

    def furthest(direction, position)
      furthests = []
      furthests << room.furthest(direction, position) if room
      if children
        children.each { |c| furthests << c.furthest(direction, position) }
      end
      furthests << corridor.furthest(direction, position) if corridor
      furthests.compact!

      case direction
      when :east
        furthests.max_by { |f| f.first }
      when :south
        furthests.max_by { |f| f.last }
      when :west
        furthests.min_by { |f| f.first }
      when :north
        furthests.min_by { |f| f.last }
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
      pos = Spreader.new(((0+desired_height)..(height-desired_height)).to_a).item(:middle)
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
      pos = Spreader.new(((0+desired_width)..(width-desired_width)).to_a).item(:middle)
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
      "<World: #{width}x#{height} at (#{x},#{y}) #{room.nil? ? '' : room.to_s}#{with_children ? ((children || []).any? ? " containing:\n  #{@children.map{|c| c.to_s }.join(',')}": '') : ''}>"
    end
  end
end
