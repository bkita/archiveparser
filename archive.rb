require 'nokogiri'
require 'open-uri'

domains = []
seo_results = []

snapshots_counter = 0

#READ DOMAINS FROM FILE
file = File.new('domains.txt', 'r')

file.each_line do |line| 
	line.delete!("\n")
    line.gsub!(/\s/,',')
	domains << line
end

#CHECK ALL DOMAINS
domains.each do |domain|

	puts "checking " + domain

	begin
		page = Nokogiri::HTML(open("http://web.archive.org/web/*/" + domain))
		
		saved_times_counter = page.css("div#wbMeta p[2] strong").text
		saved_times_counter  = saved_times_counter.delete!(" times")

		if saved_times_counter.to_i > 1
			from_date = Time.parse(page.css("div#wbMeta p[2] a[2]").text)
			from_year = from_date.strftime("%Y ")
			from_year  = from_year.delete!(" ")
		
			to_date  = Time.parse(page.css("div#wbMeta p[2] a[3]").text)
			to_year = to_date.strftime("%Y ")
			to_year  = to_year.delete!(" ")

			year_counter = to_year.to_i - from_year.to_i

			ratio = saved_times_counter.to_i / year_counter




			(from_year..to_year).each do |year|
				page = Nokogiri::HTML(open("http://web.archive.org/web/#{year}0600000000*/http://#{domain}"))   
				snapshots = page.css('div.pop')
				snapshots_counter += snapshots.size
				puts year.to_s + ' - ' + snapshots.size.to_s
			end

			puts seo_results << domain + ";" + saved_times_counter + ";" + from_year + "-" + to_year + ";" + year_counter.to_s + ";" + ratio.to_s

			#seo_results << domain + ";" + saved_times_counter + ";" + from_year + "-" + to_year + ";" + year_counter.to_s + ";" + ratio.to_s
		
		elsif saved_times_counter.to_i == 1
			from_date = Time.parse(page.css("div#wbMeta p[2] a[2]").text)
			from_year = from_date.strftime("%Y ")
			from_year  = from_year.delete!(" ")

			year_counter = 1

			seo_results << domain + ";" + saved_times_counter + ";" + from_year + ";" + year_counter.to_s + ";" + "1"
		end

	rescue Exception => e
	  	if e.message == '404 Not Found'
	    	seo_results << domain + ";" + "0" + ";" + "0" + ";" + "0" + ";" + "0"
	  	end
	end

end

#SAVE TO FILE
out_txt = File.new("out.txt", 'w')
seo_results.each {|result| out_txt.puts result}
out_txt.close

puts "DONE!"

