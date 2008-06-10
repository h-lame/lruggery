require 'yaml'

data = File.open('londoners.yml','r') {|f| YAML::load(f)}

threshold_score = data.delete(:threshold_score)

popular = data.inject({}) do |by_score, (url, data)|
  if data[:recommendations] >= 5 #[threshold_score - 20, 10].max
    by_score[data[:recommendations]] ||= []
    by_score[data[:recommendations]] << data
  end
  by_score
end

popular.keys.sort.each do |score|
  puts "#{score}: #{popular[score].map{|d| "#{d[:name]} (#{d[:url]})"}.join(', ')}"
end
