# encoding: utf-8

module Rogue
  class GameEngine
    include HighLine::SystemExtensions

    attr_reader :options

    def initialize(args)
      @options = args
    end

    def renderer
      @renderer ||= Rogue::Renderer.new(options[:width], options[:height])
    end

    def generator
      @generator ||= Rogue::Generator.new(options[:width], options[:height], options[:room_width], options[:room_height])
    end

    def choose_world!
      chosen = false
      until chosen == 'y'
        w = make_world
        renderer.render!(w)
        print("Use this world? [y/n]: ")
        chosen = get_character.chr.downcase
        puts
      end
      @world = w
    end

    def run!
      initialize_player!
      while true
        tick!
      end
    end

    def tick!
      @renderer.render! @world, @player
      print "Where to? [wasd]: "
      dir = direction_from_keypress(get_character)
      @world.move(@player, dir) unless dir.nil?
    end

    protected
    def direction_from_keypress(keypress)
      key = keypress.chr.downcase
      case key
      when 'w'
        :north
      when 'd'
        :east
      when 's'
        :south
      when 'a'
        :west
      end
    end

    def make_world
      generator.generate!(options[:max_worlds])
    end

    def initialize_player!
      @player = Player.new(@world.rooms.sample)
    end
  end
end