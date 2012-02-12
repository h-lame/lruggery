module Rogue
  class Renderer
    attr_reader :width, :height

    def initialize(width, height)
      @width = width
      @height = height
    end

    def render!(world, el_rogue = nil)
      ts = TileSet.new(width, height)
      #visit_world(world, ts)
      visit_rooms(world, ts)
      visit_corridors(world, ts)
      ts.draw_player(el_rogue) if el_rogue
      puts ts.render!
    end

    def visit_world(world, tileset)
      top_left, top_right, bottom_left, bottom_right = *world.boundaries

      tileset.draw_world(world)

      if world.children
        world.children.each { |subworld| visit_world(subworld, tileset) }
      end
    end

    def visit_rooms(world, tileset)
      if world.room
        tileset.draw_room(world.room)
      elsif world.children
        world.children.each { |subworld| visit_rooms(subworld, tileset) }
      end
    end

    def visit_corridors(world, tileset)
      if world.corridor
        tileset.draw_corridor(world.corridor)
      end
      if world.children
        world.children.each { |subworld| visit_corridors(subworld, tileset) }
      end
    end
  end
end
