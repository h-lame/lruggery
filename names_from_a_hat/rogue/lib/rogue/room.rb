module Rogue
  class Room < Space
    def self.generate!(desired_width, desired_height, within_world)
      top_left, top_right, bottom_left, bottom_right = *within_world.boundaries

      puts "Fitting a room into W: (#{desired_width}..#{within_world.width})"
      puts "Fitting a room into H: (#{desired_height}..#{within_world.height})"

      width = (desired_width..within_world.width).to_a.sample
      height = (desired_height..within_world.height).to_a.sample

      if width && height
        puts "Placing a #{width}x#{height} room into X: #{within_world.x} + (0..(#{within_world.width} - #{width}))"
        puts "Placing a #{width}x#{height} room into Y: #{within_world.y} + (0..(#{within_world.height} - #{height}))"
        x = (0..(within_world.width - width)).to_a.sample
        y = (0..(within_world.height - height)).to_a.sample
        if x && y
          new(width, height, within_world.x + x, within_world.y + y)
        else
          nil
        end
      else
        nil
      end
    end
  end
end
