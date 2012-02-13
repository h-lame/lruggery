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
      name_font = Artii::Figlet::Font.new("#{Artii::FONTPATH}/#{Artii::Base.new({}).all_fonts['doom']}")
      talk_font = Artii::Figlet::Font.new("#{Artii::FONTPATH}/#{Artii::Base.new({}).all_fonts['straight']}")
      name_text = Artii::Figlet::Typesetter.new(name_font)[@wizard.name]

      talk_texts = @wizard.talk.lines.map { |l| Artii::Figlet::Typesetter.new(talk_font, smush: false)[l.chomp] }
      rendered = "\e[2J\e[f"

      text_height = name_text.lines.count + talk_texts.map{ |t| t.lines.count }.inject(:+) + 4
      ((height - text_height) / 2).times { rendered += "\n" }

      rendered += center("You found a WIZARD called:")
      rendered += "\n"
      rendered += center(name_text, :green)
      rendered += "\n"
      rendered += center("who wants to talk to you about:")
      rendered += "\n"
      rendered += "\n"
      talk_texts.each do |talk_text|
        rendered += center(talk_text, :red)
        rendered += "\n"
      end

      puts rendered
    end

    protected
    def center(rendered_text, color = :white)
      text_width = rendered_text.lines.first.chomp.length
      pad = ((width - text_width) / 2)
      pad = 0 if pad < 0
      rendered_text.lines.inject("") { |t, l| t += "#{(" "*pad)}#{l.send(color)}" }
    end
  end
end
