require 'fiber'

random_choice = Fiber.new do |speakers|
  puts "Given: #{speakers}"
  Fiber.yield
  loop do
    chosen = speakers.delete(speakers.sample)
    Fiber.yield chosen
  end
end

our_brave_volunteers = [
  'Murray',
  'Herve',
  'Thomas',
  'Enrique',
  'Jamis & Adviti',
  'Aaron'
]

random_choice.resume our_brave_volunteers
loop do
  STDIN.gets
  speaker = random_choice.resume
  break if speaker.nil?
  puts "Chose: #{speaker}"
end
