Shoes.app :margin => 20, :title => 'Haphazard' do
  @volunteers = File.readlines(ask_open_file, chomp: true)
  @order = []

  def chosen
    {:stroke => cadetblue, :fill => chocolate}
  end

  def not_chosen
    {:stroke => cornsilk, :fill => cornflowerblue}
  end

  def been_done
    {:stroke => firebrick, :fill => teal}
  end

  def draw_name(name)
    para name, not_chosen.merge(:font => 'Comic Sans MS 12px', :margin => 5)
  end

  def draw_the_button
    button "GO GO GO RANDOM!", :width => 200, :left => 20 do
      # final state - picked all the names
      if @volunteers.empty?
        draw_final_order
      else
        # inital state - picked no names - start randomising
        if @randomising.nil?
          @randomising = true
        # even button press - pick a name as a "winner"
        elsif @randomising == true
          @volunteers.delete(@the_luckiest)
          @order << @the_luckiest
          show_the_winner @the_luckiest
          update_the_names @the_luckiest
          @randomising = false
        # odd button press - clear the screen and randomise again
        else
          hide_the_winner
          @randomising = true
        end
      end
    end
  end

  def draw_the_names
    @the_names_container = flow :margin => 20, :top => 140, :left => 20 do
      chunks = @volunteers.size / 6
      @the_names = {}
      j = 0
      5.times do |i|
        stack :width => 150 do
          @volunteers[j..chunks * (i+1)].each do |n|
            @the_names[n] = draw_name(n)
          end
        end
        j = (chunks * (i+1)) + 1
      end
      unless j >= @volunteers.size
        stack :width => 150 do
          @volunteers[j..-1].each do |n|
            @the_names[n] = draw_name(n)
          end
        end
      end
    end
  end

  def update_the_names(winner)
    @the_names[winner].replace del(winner)
    @the_names[winner].style(been_done)
  end

  def draw_final_order
    @the_names_container.remove
    @the_winner.remove
    stack :margin => 20, :left => 20 do
      @order.each_with_index do |name, idx|
        para "#{idx+1}. #{name}", not_chosen.merge(:font => 'Comic Sans MS 36px', :margin => 50)
      end
    end
  end

  def draw_the_winner
    @the_winner = para '', :font => 'Comic Sans MS 72px', :margin => 20, :stroke => chartreuse, :fill => indianred
  end

  def show_the_winner(winner)
    @the_winner.replace winner
    @the_winner.show
  end

  def hide_the_winner
    @the_winner.replace ''
    @the_winner.hide
  end

  def pick_a_winner
    @the_luckiest = @volunteers.sample
    @volunteers.each { |n| @the_names[n].style(not_chosen) }
    @the_names[@the_luckiest].style(chosen)
  end

  background lemonchiffon
  @randomising = nil

  stack do
    draw_the_button
    draw_the_winner
    draw_the_names
  end

  animate(24) do
    # if we've presed the button and haven't chosen every name yet
    if @randomising && @volunteers.size > 0
      pick_a_winner
    end
  end
end
