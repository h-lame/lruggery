module Rogue
  module Foggy
    class Tile < Rogue::Tile
      def initialize
        super
        @visible = false
      end

      def make_visible!
        @visible = true
      end

      def el_rogue_is_here!
        super
        make_visible!
      end

      def to_s
        if @visible
          super
        else
          Rogue::Tile.tiles[:empty]
        end
      end
    end
  end
end