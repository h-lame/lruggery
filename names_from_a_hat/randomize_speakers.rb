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

# Paul wants to use his own laptop, so we'll put him first or last and take him out of the random choice.
# our_brave_volunteers = ['Paul Ardeleanu', 'Ismael Celis', 'Joel Chippindale', 'Lars Jorgensen', 'Alex MacCaw', 'Anup Narkhede', 'Thomas Pomfret', 'Brent Snook', 'Murray Steele']
our_brave_volunteers = ['Ismael Celis', 'Joel Chippindale', 'Lars Jorgensen', 'Alex MacCaw', 'Anup Narkhede', 'Thomas Pomfret', 'Brent Snook', 'Murray Steele']

random_choice.resume our_brave_volunteers
while random_choice.alive? do
  STDIN.gets
  speaker = random_choice.resume
  applescript = %Q{tell application "Quicksilver" to show large type "#{speaker}"}
  
  `osascript -e '#{applescript}'`
end

