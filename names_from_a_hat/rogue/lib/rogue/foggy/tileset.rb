module Rogue
  module Foggy
    class TileSet < Rogue::TileSet
      def tile_class
        Rogue::Foggy::Tile
      end

      def draw_el_rogue(el_rogue)
        super(el_rogue)
        with_surroundings(el_rogue) do |tile|
          tile.make_visible!
        end
      end

      def with_surroundings(watcher)
        r_squared = watcher.eye_strength**2
        @tiles.each.with_index do |row, y|
          row.each.with_index do |tile, x|
            tile_score = ((x - watcher.x)**2) + ((y - watcher.y)**2)
            if tile_score <= r_squared
              yield tile
            end
          end
        end
      end
    end
  end
end
