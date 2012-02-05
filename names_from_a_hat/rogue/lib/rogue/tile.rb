# encoding: utf-8
require 'colored'

module Rogue
  class Tile
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
        horizontal: '='.blue, # ═ would be better, but it's double width
        vertical: '‖'.blue,# ║ would be better, but it's double width
        crossover: '∷'.blue # ╬ would be better, but it's double width
      },
      player: '@'.yellow
    }

    def initialize
      @content = Tiles[:empty]
      @player_is_here = false
    end

    def make_floor
      @content = Tiles[:floor]
    end

    def player_is_here!
      @player_is_here = true
    end

    def player_is_not_here!
      @player_is_here = false
    end

    def to_s
      @player_is_here ? Tiles[:player] : @content
    end

    def make_horizontal_wall(type)
      @content =
        case @content
        when Tiles[:empty]
          Tiles[type][:horizontal_wall]
        when Tiles[type][:vertical_wall], Tiles[type][:corner]
          Tiles[type][:corner]
        else
          Tiles[type][:horizontal_wall]
        end
    end

    def make_vertical_wall(type)
      @content =
        case @content
        when Tiles[:empty]
          Tiles[type][:vertical_wall]
        when Tiles[type][:horizontal_wall], Tiles[type][:corner]
          Tiles[type][:corner]
        else
          Tiles[type][:vertical_wall]
        end
    end

    def make_vertical_corridor
      @content =
        case @content
        when Tiles[:corridor][:horizontal], Tiles[:corridor][:crossover]
          Tiles[:corridor][:crossover]
        else
          Tiles[:corridor][:vertical]
        end
    end

    def make_horizontal_corridor
      @content =
        case @content
        when Tiles[:corridor][:vertical], Tiles[:corridor][:crossover]
          Tiles[:corridor][:crossover]
        else
          Tiles[:corridor][:horizontal]
        end
    end

    def make_corner(type)
      @content = Tiles[type][:corner]
    end
  end
end