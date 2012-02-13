class Spreader
  attr_accessor :array

  def initialize(array)
    @array = array
  end

  def item(algorithm = :first, spread = 2)
    probability_array = probability(spread)
    probability_array =
      case algorithm
      when :first
        probability_array
      when :middle
        # turn 1,2,3,4,5,6,... into ...6,4,2,1,3,5,...
        grouped = probability_array.each.with_index.group_by {|x| x.last.odd?}
        Array(grouped[true]).map {|x| x.first}.reverse + Array(grouped[false]).map {|x| x.first}
      when :last
        probability_array.reverse
      when :random
        # probability_array.shuffle
        array.map { 1.0/array.size }
      end
    get_weighted_random_item(probability_array)
  end

  # def item(algorithm = :first, spread = 2)
  #   probability_array = nil
  #   case algorithm
  #   when :first
  #     probability_array = probability(spread)
  #   when :middle
  #     # # turn 1,2,3,4,5,6,... into ...6,4,2,1,3,5,...
  #     # grouped = probability_array.each.with_index.group_by {|x| x.last.odd?}
  #     # Array(grouped[true]).map {|x| x.first}.reverse + Array(grouped[false]).map {|x| x.first}
  #     # turn 1,2,3,4,5,6,7 into 4,3,5,2,6,1,7
  #     probability_array = probability(spread)
  #     mid_point = array.size / 2
  #     grouped = array.map.with_index.partition {|x| x.last >= mid_point}
  #     @array = grouped.first.map {|x| x.first}.zip(grouped.last.map{|x| x.first}).flatten
  #   when :last
  #     probability_array = probability(spread).reverse
  #   when :random
  #     probability_array = array.map {|x| 1/array.size}
  #   end
  #   get_weighted_random_item(probability_array)
  # end

  def probability(spread = 2)
    z = 1.0
    array.collect {|x| z = z / spread}
  end

  def weighted_random_index(probability_array = probability(2) )
    array.size.times do |x|
      return x if rand < probability_array[0..x].inject(:+)
    end
    return 0
  end

  def get_weighted_random_item(probability_array = probability(2))
    array[weighted_random_index(probability_array)]
  end

  def get_weighted_random_indexes(num_items, p = probability(2))
    res = []
    escape = 1000
    while res.size < num_items and escape > 0
      escape -= 1
      tmp = weighted_random_index(p)
      res << tmp unless res.include?(tmp)
    end
    return res.sort
  end
end
