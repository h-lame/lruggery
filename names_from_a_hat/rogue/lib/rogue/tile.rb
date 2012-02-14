# encoding: utf-8
require 'colored'

module Rogue
  class Tile
    class << self
      attr_accessor :white_console
    end
    self.white_console = false

    BlackConsoleTiles = {
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
        horizontal: '='.blue, # ═ would be better, but it's double width
        vertical: '‖'.blue,# ║ would be better, but it's double width
        crossover: '∷'.blue # ╬ would be better, but it's double width
      },
      el_rogue: '@'.yellow,
      wizard: '¥'.magenta
    }

    WhiteConsoleTiles = {
      empty: ' ',
      floor: '.'.black,
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
        horizontal: '='.blue, # ═ would be better, but it's double width
        vertical: '‖'.blue,# ║ would be better, but it's double width
        crossover: '∷'.blue # ╬ would be better, but it's double width
      },
      el_rogue: '@'.yellow,
      wizard: '¥'.magenta
    }

    def self.tiles
      if self.white_console
        WhiteConsoleTiles
      else
        BlackConsoleTiles
      end
    end

    def initialize
      @content = Tile.tiles[:empty]
      @player_is_here = false
    end

    def make_floor
      @content = Tile.tiles[:floor]
    end

    def a_wizard_is_here!
      @a_wizard_is_here = true
    end

    def a_wizard_is_not_here!
      @a_wizard_is_here = false
    end

    def el_rogue_is_here!
      @el_rogue_is_here = true
    end

    def el_rogue_is_not_here!
      @el_rogue_is_here = false
    end

    def to_s
      if @el_rogue_is_here
        Tile.tiles[:el_rogue]
      elsif @a_wizard_is_here
        Tile.tiles[:wizard]
      else
        @content
      end
    end

    def make_horizontal_wall(type)
      @content =
        case @content
        when Tile.tiles[:empty]
          Tile.tiles[type][:horizontal_wall]
        when Tile.tiles[type][:vertical_wall], Tile.tiles[type][:corner]
          Tile.tiles[type][:corner]
        else
          Tile.tiles[type][:horizontal_wall]
        end
    end

    def make_vertical_wall(type)
      @content =
        case @content
        when Tile.tiles[:empty]
          Tile.tiles[type][:vertical_wall]
        when Tile.tiles[type][:horizontal_wall], Tile.tiles[type][:corner]
          Tile.tiles[type][:corner]
        else
          Tile.tiles[type][:vertical_wall]
        end
    end

    def make_vertical_corridor
      @content =
        case @content
        when Tile.tiles[:corridor][:horizontal], Tile.tiles[:corridor][:crossover]
          Tile.tiles[:corridor][:crossover]
        else
          Tile.tiles[:corridor][:vertical]
        end
    end

    def make_horizontal_corridor
      @content =
        case @content
        when Tile.tiles[:corridor][:vertical], Tile.tiles[:corridor][:crossover]
          Tile.tiles[:corridor][:crossover]
        else
          Tile.tiles[:corridor][:horizontal]
        end
    end

    def make_corner(type)
      @content = Tile.tiles[type][:corner]
    end
  end
end