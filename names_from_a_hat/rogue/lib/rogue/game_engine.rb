# encoding: utf-8
require 'yaml'

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
      rooms = @world.rooms.dup
      el_rogue_room = rooms.sample
      rooms.delete(el_rogue_room)
      initialize_el_rogue!(el_rogue_room)
      initialize_wizards!(rooms)
      while tick!
      end
    end

    def tick!
      @renderer.render! @world, @el_rogue, *@wizards
      print "Where to? [wasd/q]: "
      dir = direction_from_keypress(get_character)
      if dir == :quit
        return false
      else
        @world.move(@el_rogue, dir) unless dir.nil?
        return true
      end
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
      when 'q'
        :quit
      end
    end

    def make_world
      generator.generate!(options[:max_worlds])
    end

    def initialize_el_rogue!(in_room)
      @el_rogue = ElRogue.new(in_room)
    end

    def initialize_wizards!(in_rooms)
      wizards = File.open(options[:wizards_file]) { |f| YAML::load(f) }
      @wizards = wizards.map do |handle, details|
        w_room = in_rooms.sample
        in_rooms.delete(w_room)
        Wizard.new(w_room, handle, details)
      end
    end
  end
end