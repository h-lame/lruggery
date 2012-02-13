require 'artii'

module Rogue
  class Event
    attr_reader :wizard, :width, :height
    def initialize(wizard, width, height)
      @wizard = wizard
      @width = width
      @height = height
    end

    def render!
      name_font = Banner.font('doom')
      talk_font = Banner.font('straight')
      name_text = Banner.draw_text(@wizard.name, name_font)

      talk_texts = @wizard.talk.lines.map { |l| Banner.draw_text(l.chomp, talk_font, false) }

      puts Banner.render! @width, @height,
                          "You found a WIZARD called:",
                          [name_text, :green],
                          "who wants to talk to you about:",
                          "",
                          *talk_texts.map {|t| [t, :red]}

    end

    protected
  end
end
