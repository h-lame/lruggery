
class Manifestable
  attr_accessor :start_position, :shown, :manifestation, :handle
  def initialize
    @shown = false
    @manifestation = nil
    @start_position = [0,0]
  end

  # NOTE - ahh... good intentions - do I even ever use these methods?
  def show
    if @manifestation.nil?
      self.manifest()
    elsif not @shown
      @manifestation.show
      @shown = true
    end
  end

  def hide
    unless @manifestation.nil? or not @shown
      @manifestation.hide
      @shown = false
    end
  end

  def manifest(x = 20, y = 20)
    if @manifestation.nil?
      @manifestation = draw_thyself(x,y)
      @start_position = [x,y]
      @shown = true
      @manifestation.show
    else
      @manifestation.show
      @manifestation.move(x,y)
      @start_position = [x,y]
      @shown = true
    end
  end

  def draw_thyself(x, y)
    raise "Not implemented"
  end
end

class Name < Manifestable
  def initialize(handle)
    super()
    @handle = handle
    @base_size = 120
    @cur_size = nil
  end

  def draw_thyself(x, y, size = @base_size)
    $app.para(@handle, :font => "Futura #{size}px", :top => y, :left => x, :stroke => '#000')
  end

  def move_step(the_hat, scale = 24.0)
    [
     (@start_position.first - the_hat.hole.first) / scale,
     (@start_position.last - the_hat.hole.last) / scale,
     @base_size / scale
    ]
  end

  def move_towards_the_hat(the_hat)
    if @shown && @manifestation && !the_hat.contains?(self)
      @cur_size ||= @base_size
      step_l, step_t, step_size = move_step(the_hat)
      new_x = @manifestation.left - step_l
      new_y = @manifestation.top - step_t
      new_size = @cur_size - step_size
      if ((new_size <= 1) &&
          (((new_y - the_hat.hole.last).abs <= 1) &&
           ((new_x - the_hat.hole.first).abs <= 1)))
        the_hat.put_name_into_hat(self)
        self.hide
        return true
      else
        @cur_size = new_size
        @manifestation.style(size: @cur_size)
        @manifestation.move(new_x, new_y)
        return false
      end
    end
  end
end

class Hat
  MAGIC_WORDS = ['Abrakadabra', 'Sim Sala Bim', 'Hocus Pocus', 'Izzy Wizzy, let\'s get busy', 'Shazam']

  attr_accessor :hole
  def initialize()
    @hole = [0,0]
    @in_the_hat = []
    @button = nil
    @magic_star = nil
  end

  def put_name_into_hat(the_name)
    @in_the_hat << the_name
  end

  def contains?(the_name)
    @in_the_hat.map {|n| n.handle}.include? the_name
  end

  def draw_button
    @button ||= $app.button(MAGIC_WORDS.sample, :width => 200, :top => (@hole.last + 150), :left => (@hole.first - 100)) do
      if $app.winner.nil?
        $app.winner = @chosen
        @in_the_hat.delete(@chosen)
      else
        $app.winner = nil
        @button.text = MAGIC_WORDS.sample
      end
    end
  end

  def magic_boundary
    @magic_boundary ||= {
      left: (@hole.first-54..@hole.first-14).to_a,
      top: (@hole.last+15..@hole.last+55).to_a
    }
  end

  def do_magic
    @chosen = @in_the_hat.sample
    @magic_star.move(
      magic_boundary[:left].sample,
      magic_boundary[:top].sample
    )
  end

  def stop_magic
    @magic_star.move(@hole.first-34, @hole.last+35)
  end

  def manifest(x, y)
    @hole = [x+100, y+75]
    $app.nostroke

    #shadow
    $app.fill $app.gray(0.2, 0.6)
    $app.oval left: x+40, top: y+140, width: 120, height: 60

    # trunk of hat
    $app.fill '#000'
    $app.oval left: x+50, top: y+50, width: 100, height: 40
    $app.rect left: x+50, top: y+70, width: 100, height: 100
    $app.oval left: x+50, top: y+150, width: 100, height: 40

    # white band
    $app.fill '#fff'
    $app.oval left: x+50, top: y+60, width: 100, height: 40
    $app.rect left: x+50, top: y+80, width: 100, height: 10
    $app.oval left: x+50, top: y+70, width: 100, height: 40
    $app.fill '#000'
    $app.oval left: x+50, top: y+60, width: 100, height: 40

    # brim and hole
    $app.fill '#000'
    $app.oval left: x+25, top: y+35, width: 150, height: 70
    $app.fill '#444'
    $app.oval left: x+50, top: y+53, width: 100, height: 34

    # star - NOTE: wtf? with the - stuff?
    $app.fill '#fd0'
    @magic_star = $app.star(left: x+66, top: y+110, points: 7, outer: 35, inner: 18)
  end
end

Shoes.app :width => 640, :height => 480, :title => 'Names From A Hat' do
  $app = self

  @names_for_the_hat = File.readlines(ask_open_file, chomp: true)
  @prize_name = @names_for_the_hat.shift
  @going_in_the_hat = []
  @winner = nil

  def show_the_winner
    @book_name.replace(@winner.handle)
  end

  # TODO - Work out why didn't attr_accessor work here?
  def winner
    @winner
  end

  def winner=(winner)
    @winner= winner
    @book_name.replace(@prize_name) if @winner.nil?
  end

  background lemonchiffon

  @cur_name = nil

  # NOTE this is all kinds of ass.  How do real people cope with this stuff?
  def main_loop
    unless @pressed_go.nil?

      if @cur_name.nil?
        if !@names_for_the_hat.empty?
          new_name = @names_for_the_hat.pop
          @cur_name = Name.new(new_name)
          @cur_name.manifest(200, 20)
          @going_in_the_hat << @cur_name
        else
          if @winner.nil?
            @the_hat.do_magic
          else
            @the_hat.stop_magic
            show_the_winner
          end
        end
      else
        in_the_hat_yet = @cur_name.move_towards_the_hat(@the_hat)
        @cur_name = nil unless not in_the_hat_yet
        @the_hat.draw_button if @names_for_the_hat.empty? && in_the_hat_yet
      end
    end
  end

  @the_hat = Hat.new
  @the_hat.manifest(200, 200)

  @book_name = para(@prize_name, :font => 'Futura 72px', :stroke => indianred, :top => 0, :left => 0)

  @pressed_go = nil
  @the_start_button = button('Shall we begin?', :width => 200, :top => 150, :left => 100) do
    @pressed_go = 'yes'
    @the_start_button.remove
  end

  animate(24) do
    main_loop
  end

end
