module Rogue
  module Foggy
    class Renderer < Rogue::Renderer
      def new_tileset
        Foggy::TileSet.new(width, height)
      end
    end
  end
end