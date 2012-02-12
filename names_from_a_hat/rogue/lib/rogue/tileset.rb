module Rogue
  class TileSet
    def initialize(width, height)
      @tiles = []
      height.times { @tiles << (width.times.map { Tile.new }) }
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
      corridor.positions.each do |position_and_direction|
        position, direction = *position_and_direction
        case direction
        when :horizontal
          draw_horizontal_corridor_at(*position)
        when :vertical
          draw_vertical_corridor_at(*position)
        end
      end
    end

    def draw_creature(creature)
      case creature
      when Wizard
        draw_wizard(creature)
      when ElRogue
        draw_el_rogue(creature)
      end
    end

    def draw_wizard(wizard)
      @tiles[wizard.y][wizard.x].a_wizard_is_here!
    end

    def draw_el_rogue(el_rogue)
      # Probably a better way of doing this?
      # could we layer the el_rogue above the tiles?
      @tiles.flatten.each {|t| t.el_rogue_is_not_here! }
      @tiles[el_rogue.y][el_rogue.x].el_rogue_is_here!
    end

    def render!
      # clear screen first
      rendered = "\e[2J\e[f"
      @tiles.each do |row|
        rendered << row.join
        rendered << "\n"
      end
      rendered
    end

    protected
    def draw_floor_at(x,y)
      @tiles[y][x].make_floor
    end

    def draw_horizontal_wall_between(top, bottom, type)
      raise ArgumentError, "top and bottom not on same y co-ord" unless top.last == bottom.last
      (bottom.first - top.first).times do |x|
        draw_horizontal_wall_at(top.first + x, top.last, type)
      end
    end

    def draw_horizontal_wall_at(x,y, type)
      @tiles[y][x].make_horizontal_wall(type)
    end

    def draw_vertical_wall_between(left, right, type)
      raise ArgumentError, "left and right not on same x co-ord" unless left.first == right.first
      (right.last - left.last).times do |y|
        draw_vertical_wall_at(left.first, left.last + y, type)
      end
    end

    def draw_vertical_wall_at(x,y, type)
      @tiles[y][x].make_vertical_wall(type)
    end

    def draw_vertical_corridor_at(x,y)
      @tiles[y][x].make_vertical_corridor
    end

    def draw_horizontal_corridor_at(x,y)
      @tiles[y][x].make_horizontal_corridor
    end

    def draw_corner_at(x,y, type)
      @tiles[y][x].make_corner(type)
    end
  end
end