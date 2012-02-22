require 'artii'
require 'colored'
require './lib/rogue/banner'

# ['univers',
# 'slant',
# 'rounded',
# 'puffy',
# 'nvscript',
# 'larry3d',
# 'graffiti',
# 'graceful',
# 'fraktur',
# 'epic'].each do |font_name|

# ['roman',
#  'doh',
#  

Rogue::Banner::FONT_REPO.all_fonts.keys.each do |font_name|
  begin
    f = Artii::Figlet::Font.new("#{Artii::FONTPATH}/#{Rogue::Banner::FONT_REPO.all_fonts[font_name]}")
    t_smush = Artii::Figlet::Typesetter.new(f, smush: true)["El Rogue"]
    t_no_smush = Artii::Figlet::Typesetter.new(f, smush: false)["El Rogue"]
    puts font_name
    puts
    puts "No smushing:"
    puts t_no_smush.red
    puts
    puts "With smushing:"
    puts t_smush.red
    puts
  rescue
    puts font_name
    puts
    puts "is broke :(".green
    puts
  end
end