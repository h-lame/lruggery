module Rogue
  class Banner
    FONT_REPO = Artii::Base.new({})

    def self.center(width, height, rendered_text, color = :white)
      if rendered_text.nil? || rendered_text.lines.first.nil?
        ""
      else
        text_width = rendered_text.lines.first.chomp.length
        pad = ((width - text_width) / 2)
        pad = 0 if pad < 0
        rendered_text.lines.inject("") { |t, l| t += "#{(" "*pad)}#{l.send(color)}" }
      end
    end

    def self.font(font_name)
      Artii::Figlet::Font.new("#{Artii::FONTPATH}/#{FONT_REPO.all_fonts[font_name]}")
    end

    def self.draw_text(text, font, smush = true)
      Artii::Figlet::Typesetter.new(font, smush: smush)[text]
    end

    def self.render!(width, height, *texts)
      rendered = "\e[2J\e[f"

      text_height = texts.map { |t|
        if t.is_a? String
          t.lines.count
        else
          t.first.lines.count
        end
      }.inject(:+)
      ((height - text_height) / 2).times { rendered += "\n" }

      texts.each do |t|
        rendered += center(width, height, *t)
        rendered += "\n"
      end

      rendered
    end
  end
end