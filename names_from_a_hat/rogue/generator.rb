module Rogue
  class Generator
    attr_reader :width, :height, :desired_room_width, :desired_room_height

    def initialize(width, height, desired_room_width, desired_room_height)
      @width = width
      @height = height
      @desired_room_height = desired_room_height
      @desired_room_width = desired_room_width
    end

    def generate!
      w = World.new(width, height, 0, 0)
      while w.splittable?(desired_room_width, desired_room_height)
        w.split!(desired_room_width, desired_room_height)
      end
      w
    end
  end

  class World
    attr_reader :width, :height, :x, :y, :children

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

    def splittable?(desired_width, desired_height)
      if children.nil?
        possible_directions(desired_width, desired_height).any?
      else
        children.any? { |c| c.splittable?(desired_width, desired_height) }
      end
    end

    def split_horizontally(desired_width, desired_height)
      pos = ((0+desired_height)..(@height-desired_height)).to_a.sample
      @children =
        if pos
          [
            World.new(width, pos, x, y),
            World.new(width, (height - pos + 1), x, (y + pos - 1))
          ]
        else
          []
        end
    end
    
    def split_vertically(desired_width, desired_height)
      pos = ((0+desired_width)..(@width-desired_width)).to_a.sample
      @children =
        if pos
          [
            World.new(pos, height, x, y),
            World.new((width - pos + 1), height, (x + pos - 1), y)
          ]
        else
          []
        end
    end
    
    def possible_directions(desired_width, desired_height)
      options = []
      options << :horizontal if (width * 2) >= desired_width
      options << :vertical if (height * 2) >= desired_height
      options
    end
    
    def to_s
      "<World: #{width}x#{height} at (#{x},#{y})#{children.any? ? " containing:\n\t#{@children.map{|c| c.to_s }.join(',')}": ''}>"
    end
  end
  
  class Renderer
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end

    def render!(world)
      ts = TileSet.new(width, height)
      visit(world, ts)
      puts ts.render!
    end

    def visit(world, tileset)
      top_left, top_right, bottom_left, bottom_right = *world.boundaries
      tileset.draw_corner(*top_left)
      tileset.draw_corner(*top_right)
      tileset.draw_corner(*bottom_left)
      tileset.draw_corner(*bottom_right)
      
      tileset.draw_vertical_wall_between(top_left, bottom_left)
      tileset.draw_vertical_wall_between(top_right, bottom_right)

      tileset.draw_horizontal_wall_between(top_left, top_right)
      tileset.draw_horizontal_wall_between(bottom_left, bottom_right)

      world.children.each { |subworld| visit(subworld, tileset) }
    end
  end
  
  class TileSet
    EMPTY = ' '
    CORNER = '+'
    HORIZONTAL_WALL = '-'
    VERTICAL_WALL = '|'
    def initialize(width, height)
      @tiles = []
      height.times { @tiles << [TileSet::EMPTY] * width }
    end

    def draw_horizontal_wall(x,y)
      @tiles[y][x] =
        if @tiles[y][x] == EMPTY
          HORIZONTAL_WALL
        elsif @tiles[y][x] == VERTICAL_WALL || @tiles[y][x] == CORNER
          CORNER
        else
          HORIZONTAL_WALL
        end
    end

    def draw_vertical_wall(x,y)
      @tiles[y][x] =
        if @tiles[y][x] == EMPTY
          VERTICAL_WALL
        elsif @tiles[y][x] == HORIZONTAL_WALL || @tiles[y][x] == CORNER
          CORNER
        else
          VERTICAL_WALL
        end
    end

    def draw_horizontal_wall_between(top, bottom)
      raise ArgumentError, "top and bottom not on same y co-ord" unless top.last == bottom.last
      (bottom.first - top.first).times do |x|
        draw_horizontal_wall(top.first + x, top.last)
      end
    end

    def draw_vertical_wall_between(left, right)
      raise ArgumentError, "left and right not on same x co-ord" unless left.first == right.first
      (right.last - left.last).times do |y|
        draw_vertical_wall(left.first, left.last + y)
      end
    end

    def draw_corner(x,y)
      @tiles[y][x] = CORNER
    end
    
    def render!
      rendered = ''
      @tiles.each do |row|
        rendered << row.join
        rendered << "\n"
      end
      rendered
    end
  end
end
