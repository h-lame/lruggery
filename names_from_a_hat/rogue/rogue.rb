# encoding: utf-8
require 'trollop'
require 'highline/system_extensions'

include HighLine::SystemExtensions

window = terminal_size

opts = Trollop::options do
  opt :width, "World width", :default => window.first
  opt :height, "World height", :default => window.last - 1
  opt :max_worlds, "How many sub-worlds to generate", :default => 10
  opt :room_width, "Desired room width", :default => 6, :short => 'W'
  opt :room_height, "Desired room height", :default => 6, :short => 'H'
end

require './lib/rogue'

ge = Rogue::GameEngine.new(opts)

ge.choose_world!
ge.run!