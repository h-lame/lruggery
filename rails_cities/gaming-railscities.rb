gem 'hpricot'
require 'hpricot'
require 'open-uri'
require 'yaml'


popular = Hpricot(open("http://www.workingwithrails.com/browse/popular/people"))

bottom_score = popular.search("#Main//tr:last-of-type//span").first.inner_html.match(/\((\d+)\)/)[1].to_i

doc = Hpricot(open("http://www.workingwithrails.com/browse/people/country/United+Kingdom"))
#doc =  open("countries.html") { |f| Hpricot(f) }

londoners = doc.search("ul.entry-list/li[span:contains('London')]")

#londoners = londoners[182..-1]

puts "Looking at #{londoners.size} London rubyists"

File.open('londoners.yml','w+') do |output|
  output.write({:threshold_score => bottom_score}.to_yaml)
  @all_the_data = londoners.inject({}) do |bits, londoner| 
    url = londoner.search('a').first.attributes['href']
    puts "#{bits.size + 1}. Looking at: #{url}"
  
    persondoc = Hpricot(open(url))

    opted_out = persondoc.search("#Main p")
    if opted_out && opted_out.first && opted_out.first.inner_html
      if opted_out.first.inner_html =~ /Has chosen to opt out their profile/
        puts "Opted out :("
      else
        name = persondoc.search('h2.fn').first.inner_html.strip
        bits[url] = {:name => name, :url => url}
        if recommendations = persondoc.search('div#person-recommendation-for-summary/h3').first
          recommendation_str = recommendations.inner_html.strip
          bits[url][:recommendations] = if m = recommendation_str.match(/\((<.*?>)?(\d+)(<\/a>)?\)/)
                                     m[2].to_i
                                   else
                                     0
                                   end
        else
          puts "No recommendations section, must be a DSC employee"
          bits[url][:recommendations] = 0
        end

        puts bits[url].inspect
    
        output.write({url => bits[url]}.to_yaml[5..-1]) # trim the yaml hdr
      end
    end
    sleep 2
    
    bits
  end
end

File.open('londoners_backup.yml', 'w') do |f|
  f.write({:threshold_score => bottom_score}.to_yaml)
  f.write(@all_the_data.to_yaml)
end
