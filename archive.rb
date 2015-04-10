require 'nokogiri'
require 'open-uri'

domains = []
seo_results = []
img_dates = []
dates_to_check = []
empty_dates = []
snapshots_counter = 0
result = ""

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

		img_dates = page.at_xpath('//*[@id="sparklineImgId"]/@src').to_s.split("_")
		
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

			if year_counter.between?(5, 8)
				img_dates.each do |date|
					if date.include? ":"
						if !date.include? "000000000000"
							year = date[0,4]
							dates_to_check << year
							page = Nokogiri::HTML(open("http://web.archive.org/web/#{year}0600000000*/http://#{domain}"))   
							snapshots = page.css('div.pop')
							result += year.to_s + "[" + snapshots.size.to_s + "]" + " "
						else
							if date[0,4].to_i >= from_year.to_i
								year = date[0,4]
								empty_dates << year
								result += year.to_s + "[!]" + " "
							end
						end
					end
				end

				puts result
				img_dates.clear
				dates_to_check.clear
				empty_dates.clear
				snapshots_counter = 0
				result = ""
			end
			
			#seo_results << domain + ";" + saved_times_counter + ";" + from_year + "-" + to_year + ";" + year_counter.to_s + ";" + ratio.to_s
		
		elsif saved_times_counter.to_i == 1
			from_date = Time.parse(page.css("div#wbMeta p[2] a[2]").text)
			from_year = from_date.strftime("%Y ")
			from_year  = from_year.delete!(" ")
			year_counter = 1

			#seo_results << domain + ";" + saved_times_counter + ";" + from_year + ";" + year_counter.to_s + ";" + "1"
		end

	rescue Exception => e
	  	if e.message == '404 Not Found'
	    	seo_results << domain + ";" + "0" + ";" + "0" + ";" + "0" + ";" + "0"
	  	end
	end

end

#SAVE TO FILE
#out_txt = File.new("out.txt", 'w')
#seo_results.each {|result| out_txt.puts result}
#out_txt.close

puts "DONE!"

