module Rogue
  class Corridor
    def self.horizontal(left, right)
      left_slice = left.slice_vertically
      right_slice = right.slice_vertically
      facing = left_slice & right_slice
      if facing.any?
        joiner = Spreader.new(facing).item(:middle)
        new(left.furthest(:east, joiner),
            right.furthest(:west, joiner),
            :horizontal)
      elsif left_slice.any? && right_slice.any?
        east_point = Spreader.new(left_slice).item(:random)
        west_point = Spreader.new(right_slice).item(:random)
        new(left.furthest(:east, east_point),
            right.furthest(:west, west_point),
            :horizontal)
      end
    end

    def self.vertical(top, bottom)
      top_slice = top.slice_horizontally
      bottom_slice = bottom.slice_horizontally
      facing = top_slice & bottom_slice
      if facing.any?
        joiner = Spreader.new(facing).item(:middle)
        new(top.furthest(:south, joiner),
            bottom.furthest(:north, joiner),
            :vertical)
      elsif top_slice.any? && bottom_slice.any?
        north_point = Spreader.new(bottom_slice).item(:random)
        south_point = Spreader.new(top_slice).item(:random)
        new(top.furthest(:south, south_point),
            bottom.furthest(:north, north_point),
            :vertical)
      end
    end

    attr_accessor :positions, :start, :finish, :direction

    def initialize(start, finish, direction)
      @start = start
      @finish = finish
      @direction = direction
      @positions = generate_positions!
    end

    def generate_positions!
      case direction
      when :horizontal
        if start.last == finish.last
          generate_straight(start, finish, :horizontal)
        else
          generate_zed(start, finish, :horizontal)
        end
      when :vertical
        if start.first == finish.first
          generate_straight(start, finish, :vertical)
        else
          generate_zed(start, finish, :vertical)
        end
      end
    end

    def generate_straight(s, f, d)
      case d
      when :horizontal
        (s.first..f.first).map { |x| [[x, s.last], :horizontal] }
      when :vertical
        (s.last..f.last).map { |y| [[s.first, y], :vertical] }
      end
    end

    def generate_zed(s, f, d)
      left, right = [s, f].sort_by { |p| p.first }
      top, bottom = [s, f].sort_by { |p| p.last }
      case d
      when :horizontal
        jink = Spreader.new((left.first..right.first).to_a).item(:middle)
        generate_straight(s, [jink, s.last], :horizontal) +
        generate_straight([jink, f.last], f, :horizontal) +
        generate_straight([jink, top.last], [jink, bottom.last], :vertical)
      when :vertical
        jink = Spreader.new((top.last..bottom.last).to_a).item(:middle)
        generate_straight(s, [s.first, jink], :vertical) +
        generate_straight([f.first, jink], f, :vertical) +
        generate_straight([left.first, jink], [right.first, jink], :horizontal)
      end
    end

    def slice_horizontally
      positions.map {|p| p.first}.map {|pos| pos.first}.uniq
    end

    def slice_vertically
      positions.map {|p| p.first}.map {|pos| pos.last}.uniq
    end

    def furthest(direction, position)
      case direction
      when :east
        positions.map {|p| p.first}.select { |p| p.last == position }.max_by { |p| p.first }
      when :west
        positions.map {|p| p.first}.select { |p| p.last == position }.min_by { |p| p.first }
      when :north
        positions.map {|p| p.first}.select { |p| p.first == position }.min_by { |p| p.last }
      when :south
        positions.map {|p| p.first}.select { |p| p.first == position }.max_by { |p| p.last }
      end
    end
  end
end
