# encoding: utf-8
require 'colored'

module Rogue
  class TileSet
    Tiles = {
      empty: ' ',
      floor: '.'.white,
      room: {
        corner: '+'.red,
        horizontal_wall: '-'.red,
        vertical_wall: '|'.red,
      },
      world: {
        corner: '+'.green,
        horizontal_wall: '-'.green,
        vertical_wall: '|'.green
      },
      corridor: {
        horizontal: '█'.blue,
        vertical: '█'.blue,
      }
    }

    def initialize(width, height)
      @tiles = []
      height.times { @tiles << ([TileSet::Tiles[:empty]] * width) }
    end

    def draw_room(room)
      top_left, top_right, bottom_left, bottom_right = *room.boundaries
      draw_corner_at(*top_left, :room)
      draw_corner_at(*top_right, :room)
      draw_corner_at(*bottom_left, :room)
      draw_corner_at(*bottom_right, :room)

      draw_vertical_wall_between(*room.wall(:east), :room)
      draw_vertical_wall_between(*room.wall(:west), :room)

      draw_horizontal_wall_between(*room.wall(:north), :room)
      draw_horizontal_wall_between(*room.wall(:south), :room)

      ((top_left.first + 1)..(top_right.first - 1)).each do |floor_x|
        ((top_left.last + 1)..(bottom_left.last - 1)).each do |floor_y|
          draw_floor_at(floor_x, floor_y)
        end
      end
    end

    def draw_world(world)
      top_left, top_right, bottom_left, bottom_right = *world.boundaries

      draw_corner_at(*top_left, :world)
      draw_corner_at(*top_right, :world)
      draw_corner_at(*bottom_left, :world)
      draw_corner_at(*bottom_right, :world)

      draw_vertical_wall_between(*world.wall(:west), :world)
      draw_vertical_wall_between(*world.wall(:east), :world)

      draw_horizontal_wall_between(*world.wall(:north), :world)
      draw_horizontal_wall_between(*world.wall(:south), :world)
    end

    def draw_corridor(corridor)
      corridor.positions.each do |position|
        draw_corridor_at(*position)
      end
    end

    def draw_corridor_at(x,y)
      draw_vertical_corridor_at(x,y)
    end

    def draw_vertical_corridor_at(x,y)
      @tiles[y][x] = Tiles[:corridor][:vertical]
    end

    def draw_horizontal_corridor_at(x,y)
      @tiles[y][x] = Tiles[:corridor][:horizontal]
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
    def draw_floor_at(x,y)
      @tiles[y][x] = Tiles[:floor]
    end

    def draw_horizontal_wall_between(top, bottom, type)
      raise ArgumentError, "top and bottom not on same y co-ord" unless top.last == bottom.last
      (bottom.first - top.first).times do |x|
        draw_horizontal_wall_at(top.first + x, top.last, type)
      end
    end

    def draw_horizontal_wall_at(x,y, type)
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
        draw_vertical_wall_at(left.first, left.last + y, type)
      end
    end

    def draw_vertical_wall_at(x,y, type)
      @tiles[y][x] =
        if @tiles[y][x] == Tiles[:empty]
          Tiles[type][:vertical_wall]
        elsif @tiles[y][x] == Tiles[type][:horizontal_wall] || @tiles[y][x] == Tiles[type][:corner]
          Tiles[type][:corner]
        else
          Tiles[type][:vertical_wall]
        end
    end

    def draw_corner_at(x,y, type)
      @tiles[y][x] = Tiles[type][:corner]
    end
  end
end