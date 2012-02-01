module Rogue
  class Renderer
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end

    def render!(world)
      ts = TileSet.new(width, height)
      visit_world(world, ts)
      visit_rooms(world, ts)
      visit_corridors(world, ts)
      puts ts.render!
    end

    def render_world!(world)
      ts = TileSet.new(width, height)
      visit_world(world, ts)
      puts ts.render!
    end

    def render_rooms!(world)
      ts = TileSet.new(width, height)
      visit_rooms(world, ts)
      puts ts.render!
    end

    def visit_world(world, tileset)
      top_left, top_right, bottom_left, bottom_right = *world.boundaries
      tileset.draw_world_corner(*top_left)
      tileset.draw_world_corner(*top_right)
      tileset.draw_world_corner(*bottom_left)
      tileset.draw_world_corner(*bottom_right)

      tileset.draw_world_vertical_wall_between(top_left, bottom_left)
      tileset.draw_world_vertical_wall_between(top_right, bottom_right)

      tileset.draw_world_horizontal_wall_between(top_left, top_right)
      tileset.draw_world_horizontal_wall_between(bottom_left, bottom_right)

      if world.children
        world.children.each { |subworld| visit_world(subworld, tileset) }
      end
    end

    def visit_rooms(world, tileset)
      if world.room
        top_left, top_right, bottom_left, bottom_right = *world.room.boundaries
        tileset.draw_room_corner(*top_left)
        tileset.draw_room_corner(*top_right)
        tileset.draw_room_corner(*bottom_left)
        tileset.draw_room_corner(*bottom_right)

        tileset.draw_room_vertical_wall_between(top_left, bottom_left)
        tileset.draw_room_vertical_wall_between(top_right, bottom_right)

        tileset.draw_room_horizontal_wall_between(top_left, top_right)
        tileset.draw_room_horizontal_wall_between(bottom_left, bottom_right)
      elsif world.children
        world.children.each { |subworld| visit_rooms(subworld, tileset) }
      end
    end

    def visit_corridors(world, tileset)
      if world.corridor
        world.corridor.positions.each do |position|
          case world.corridor.direction
          when :north, :south
            tileset.draw_vertical_corridor(*position)
          when :east, :west
            tileset.draw_horizontal_corridor(*position)
          end
        end
      end
      if world.children
        world.children.each { |subworld| visit_corridors(subworld, tileset) }
      end
    end
  end
end
