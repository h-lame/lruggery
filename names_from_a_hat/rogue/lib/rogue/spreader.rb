class Spreader
  attr_accessor :array

  def initialize(array)
    @array = array
  end
    
  def probability(spread = 2)
    z = 1.0
    array.collect {|x| z = z / spread}.shuffle
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
