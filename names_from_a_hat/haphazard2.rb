
Shoes.app :margin => 20, :title => 'Haphazard' do
  the_file_path = ask_open_file
  
  @death_row = File.open(the_file_path) {|f| f.readlines }.map{|l| l.chomp}
  # Can't make this work, even on Intel Macs with video :(
  # @drumroll = video(File.expand_path(File.dirname(__FILE__) + '/jazz-drumroll.mp3'))
  # @drumroll.stop()
  # @drumroll.hide()
  # @fanfare = video(File.expand_path(File.dirname(__FILE__) + '/fanfare.mp3'))
  # @fanfare.stop()
  # @fanfare.hide()
  
  @order = []
  @the_order = nil
  
  def chosen
    {:stroke => cadetblue, :fill => chocolate}
  end
  
  def not_chosen
    {:stroke => cornsilk, :fill => cornflowerblue}
  end
  
  def been_done
    {:stroke => firebrick, :fill => teal}
  end
  
  def make_name(n)
    para n, not_chosen.merge(:font => 'Comic Sans MS 12px', :margin => 5)
  end
  
  def make_the_button
    button "GO GO GO RANDOM!", :width => 200, :left => 20 do
      if @death_row.empty?
        @the_names.remove()
        @the_dood.remove()
        stack :margin => 20, :left => 20 do
          @order.each_with_index do |name, idx|
            para "#{idx+1}. #{name}", not_chosen.merge(:font => 'Comic Sans MS 36px', :margin => 50)
          end
        end
      elsif @the_order.nil?
        if @randomator_says_go.nil?
          @randomator_says_go = true
        elsif @randomator_says_go == true
          # @drumroll.stop
          # @fanfar.time = 0
          # @fanfare.play
          @randomator_says_go = false
          @death_row.delete(@the_luckiest)
          @the_doods[@the_luckiest].replace del(@the_luckiest)
          @the_doods[@the_luckiest].style(been_done)
          @the_dood.replace @the_luckiest
          @the_dood.show
          @order << @the_luckiest
        else
          # @drumroll.time = 0
          # @drumroll.play
          @the_dood.replace ''
          @the_dood.hide
          @randomator_says_go = true
        end
      end
    end
  end
  
  def draw_the_names
    @the_names = flow do
      chunks = @death_row.size / 6
      @the_doods = {}
      j = 0
      5.times do |i|
        stack :width => 150 do
          @death_row[j..chunks * (i+1)].each do |n|
            @the_doods[n] = make_name(n)
          end
        end
        j = (chunks * (i+1)) + 1
      end
      unless j >= @death_row.size
        stack :width => 150 do
          @death_row[j..-1].each do |n|
            @the_doods[n] = make_name(n)
          end
        end
      end
      # @the_doods = @death_row.inject({}) do |h, n|
      #         h[n] = make_name(n)
      #         h
      #       end
    end
  end
  
  def show_the_winner
    @the_dood = para '', :font => 'Comic Sans MS 72px', :margin => 20, :stroke => chartreuse, :fill => indianred
  end
  
  background lemonchiffon
  @randomator_says_go = nil
  #@death_row = names
  
  stack do
    make_the_button
    show_the_winner
    draw_the_names
  end
  
  animate(24) do 
    if @randomator_says_go && @death_row.size > 0
      @the_luckiest = @death_row[rand(@death_row.size)]
      @death_row.each {|n| @the_doods[n].style(not_chosen)}
      @the_doods[@the_luckiest].style(chosen)
    end
  end
end