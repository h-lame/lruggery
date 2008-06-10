
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
    @base_size = 20
    @cur_size = nil
  end
  
  def draw_thyself(x, y, size = @base_size)
    $app.para(@handle, :font => "Comic Sans MS #{size}px", :top => x, :left => y, :stroke => '#000')
  end
  
  def size_step
    @base_size / 24.0
  end
  
  def move_step(the_hat)
    [(@start_position.first - the_hat.hole.first) / 24.0, (@start_position.last - the_hat.hole.last) / 24.0]
  end
  
  def move_towards_the_hat(the_hat)
    begin
      if @shown && @manifestation && !the_hat.contains?(self)
        step_f = size_step
        @cur_size ||= @base_size
        @cur_size = @cur_size - step_f
        step_t, step_l = move_step(the_hat)
        new_x = @manifestation.left - step_l
        new_y = @manifestation.top - step_t
        if ((@cur_size <= 1) && 
            (((@manifestation.top - the_hat.hole.first - step_t) <= 0) && 
             ((@manifestation.left - the_hat.hole.last - step_l) <= 0)))
          the_hat.put_name_into_hat(self)
          self.hide
          return true
        else
          @manifestation.style(:font => "Futura #{@cur_size}px") if @cur_size > 1
          @manifestation.move(new_x, new_y)
          return false
        end
      end
    rescue Object => e
      alert e.message + "\n" + e.backtrace.join("\n")
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
  
  def button_shown?
    !@button.nil?
  end
  
  def draw_button
    @button = $app.button(MAGIC_WORDS[rand(MAGIC_WORDS.size)], :width => 200, :top => (@hole.last + 150), :left => (@hole.first - 100)) do
      if $app.winner.nil?
        $app.winner = @chosen
        @in_the_hat.delete(@chosen)
      else
        $app.winner = nil
      end
      @button.remove
      draw_button
    end
  end
  
  def do_magic
    @chosen = @in_the_hat[rand(@in_the_hat.size)]
    @magic_star.move([*(@hole.first-180..@hole.first-140)][rand(40)],[*(@hole.last-125..@hole.last-85)][rand(40)])
  end
  
  def manifest(x, y)
    @hole = [x+100, y+75]
    $app.nostroke

    #shadow
    # fill gray(0.2,1.0)
    # oval x+40, y+140, 120, 60

    # trunk of hat
    $app.fill '#000'
    $app.oval x+50, y+50, 100, 40
    $app.rect x+50, y+70, 100, 100
    $app.oval x+50, y+150, 100, 40

    # white band
    $app.fill '#fff'
    $app.oval x+50, y+60, 100, 40
    $app.rect x+50, y+80, 100, 10
    $app.oval x+50, y+70, 100, 40
    $app.fill '#000'
    $app.oval x+50, y+60, 100, 40

    # brim and hole
    $app.fill '#000'
    $app.oval x+25, y+35, 150, 70
    $app.fill '#444'
    $app.oval x+50, y+53, 100, 34
    
    # star - NOTE: wtf? with the - stuff?
    $app.fill '#fd0'
    @magic_star = $app.star(x-60, y-30, 5, 40)
  end
end

Shoes.app :width => 640, :height => 480, :title => 'Names From A Hat' do
  
  $app = self
  the_file_path = ask_open_file
  
  @names_for_the_hat = File.open(the_file_path) {|f| f.readlines }.map{|l| l.chomp}
  
  @book_name_str = @names_for_the_hat.shift
  
  @going_in_the_hat = []
  @winner = nil
  
  def show_the_winner
    @book_name.replace(@winner.handle)
  end
  
  # TOOD - Work out why didn't attr_accessor work here?
  def winner
    @winner
  end
  
  def winner=(winner)
    @winner= winner
    @book_name.replace(@book_name_str) if @winner.nil?
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
          @cur_name.manifest(20, 200)
          @going_in_the_hat << @cur_name
        else
          if @winner.nil?
            @the_hat.do_magic
          else
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

  @book_name = para(@book_name_str, :font => 'Futura 72px', :stroke => indianred, :top => 0, :left => 0)

  @pressed_go = nil
  @the_start_button = button('Shall we begin?', :width => 200, :top => 150, :left => 100) do
    @pressed_go = 'yes'
    @the_start_button.remove
  end
  
  animate(24) do
    main_loop
  end
  
end