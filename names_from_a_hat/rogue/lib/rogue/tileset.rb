require 'colored'

module Rogue
  class TileSet
    Tiles = {
      empty: ' ',
      room: {
        corner: '+'.red,
        horizontal_wall: '-'.red,
        vertical_wall: '|'.red
      },
      world: {
        corner: '+'.green,
        horizontal_wall: '-'.green,
        vertical_wall: '|'.green
      }
    }

    def initialize(width, height)
      @tiles = []
      height.times { @tiles << ([TileSet::Tiles[:empty]] * width) }
    end

    def draw_room_horizontal_wall(x,y)
      draw_horizontal_wall(x,y, :room)
    end

    def draw_room_vertical_wall(x,y)
      draw_vertical_wall(x,y, :room)
    end

    def draw_room_horizontal_wall_between(top, bottom)
      draw_horizontal_wall_between(top, bottom, :room)
    end

    def draw_room_vertical_wall_between(left, right)
      draw_vertical_wall_between(left, right, :room)
    end

    def draw_room_corner(x,y)
      draw_corner(x,y, :room)
    end

    def draw_world_horizontal_wall(x,y)
      draw_horizontal_wall(x,y, :world)
    end

    def draw_world_vertical_wall(x,y)
      draw_vertical_wall(x,y, :world)
    end

    def draw_world_horizontal_wall_between(top, bottom)
      draw_horizontal_wall_between(top, bottom, :world)
    end

    def draw_world_vertical_wall_between(left, right)
      draw_vertical_wall_between(left, right, :world)
    end

    def draw_world_corner(x,y)
      draw_corner(x,y, :world)
    end
    
    def render!
      rendered = ''
      @tiles.each do |row|
        rendered << row.join
        rendered << "\n"
      end
      rendered
    end
    
    protected
    def draw_horizontal_wall_between(top, bottom, type)
      raise ArgumentError, "top and bottom not on same y co-ord" unless top.last == bottom.last
      (bottom.first - top.first).times do |x|
        draw_horizontal_wall(top.first + x, top.last, type)
      end
    end
      
    def draw_horizontal_wall(x,y, type)
      @tiles[y][x] =
        if @tiles[y][x] == Tiles[:empty]
          Tiles[type][:horizontal_wall]
        elsif @tiles[y][x] == Tiles[type][:vertical_wall] || @tiles[y][x] == Tiles[type][:corner]
          Tiles[type][:corner]
        else
          Tiles[type][:horizontal_wall]
        end
    end

    def draw_vertical_wall_between(left, right, type)
      raise ArgumentError, "left and right not on same x co-ord" unless left.first == right.first
      (right.last - left.last).times do |y|
        draw_vertical_wall(left.first, left.last + y, type)
      end
    end

    def draw_vertical_wall(x,y, type)
      @tiles[y][x] =
        if @tiles[y][x] == Tiles[:empty]
          Tiles[type][:vertical_wall]
        elsif @tiles[y][x] == Tiles[type][:horizontal_wall] || @tiles[y][x] == Tiles[type][:corner]
          Tiles[type][:corner]
        else
          Tiles[type][:vertical_wall]
        end
    end

    def draw_corner(x,y, type)
      @tiles[y][x] = Tiles[type][:corner]
    end
  end
end