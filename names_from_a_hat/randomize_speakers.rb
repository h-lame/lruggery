require 'fiber'

random_choice = Fiber.new do |speakers|
  puts "Given: #{speakers}"
  Fiber.yield
  loop do
    break if speakers.empty?
    chosen = speakers.delete_at(rand(speakers.size))
    puts "Chose: #{chosen}"
    Fiber.yield chosen
  end
end


random_choice.resume ['Paul Ardeleanu', 'Ismael Celis', 'Joel Chippindale', 'Lars Jorgensen', 'Alex MacCaw', 'Anup Narkhede', 'Thomas Pomfret', 'Brent Snook', 'Murray Steele']
while random_choice.alive? do
  STDIN.gets
  speaker = random_choice.resume
  applescript = %Q{tell application "Quicksilver" to show large type "#{speaker}"}
  
  `osascript -e '#{applescript}'`
end

