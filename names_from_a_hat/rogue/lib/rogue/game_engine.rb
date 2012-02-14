# encoding: utf-8
require 'yaml'

module Rogue
  class GameEngine
    include HighLine::SystemExtensions

    attr_reader :options

    def initialize(args)
      @options = args
      Banner.white_console = args[:white_console]
      Tile.white_console = args[:white_console]
    end

    def renderer
      @renderer ||= Rogue::Renderer.new(options[:width], options[:height])
    end

    def generator
      @generator ||= Rogue::Generator.new(options[:width], options[:height], options[:room_width], options[:room_height])
    end

    def choose_world!
      chosen = 'n'
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
      display_history!
    end

    def tick!
      check_for_events!
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

    def display_all_wizards!
      tmp_space = Space.new(3,3,0,0)
      wizards = File.open(options[:wizards_file]) { |f| YAML::load(f) }
      wizards.map do |handle, details|
        display_event(Wizard.new(tmp_space, handle, details))
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

    def check_for_events!
      found = @wizards.detect {|w| @el_rogue.on_top_of?(w) }
      if found
        @wizards.delete(found)
        @defeated << found
        display_event(found)
        print "Continue [Y]: "
        while get_character.chr.downcase != 'y' do
        end
      end
    end

    def display_event(wizard)
      Event.new(wizard, options[:width], options[:height]).render!
    end

    def display_history!
      wizard_font = Banner.font('stop')
      wizard_texts =
        if @defeated.any?
          @defeated.map.with_index { |w,i| [Banner.draw_text("#{i+1}. #{w.name}", wizard_font, false), :green] }
        else
          [[Banner.draw_text("NONE! You idiot!", wizard_font), :red]]
        end
      puts Banner.render! options[:width], options[:height],
                          "You met the following wizards:",
                          "",
                          *wizard_texts.map {|wt| [wt, ""] }.flatten(1),
                          "",
                          "Hurrah!"
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
      @defeated = []
    end
  end
end