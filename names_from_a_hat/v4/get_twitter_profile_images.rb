#!/user/bin/env ruby

url = "http://api.twitter.com/1/users/profile_image/<screen_name>.json?size=bigger"

require 'open-uri'

File.open(ARGV[0],'r') do |list_of_twitter_names|
  list_of_twitter_names.lines.each do |twitter_name|
    twitter_name.gsub!(/^@/,'').strip!
    File.open("#{twitter_name}.png",'w') do |profile_image|
      profile_image.write(open(url.gsub(/<screen_name>/, twitter_name)).read)
    end
  end
end
