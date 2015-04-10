require 'rubygems'
require 'nokogiri'
require 'open-uri'

domain = "betonowe-szamba.pl"
snapshots_counter = 0
img_dates = []
dates_to_check = []
empty_dates = []
result = ""

page = Nokogiri::HTML(open("https://web.archive.org/web/*/#{domain}")) 
img_dates = page.at_xpath('//*[@id="sparklineImgId"]/@src').to_s.split("_")

from_date = Time.parse(page.css("div#wbMeta p[2] a[2]").text)
from_year = from_date.strftime("%Y ")
from_year  = from_year.delete!(" ")

img_dates.each do |date|
	if date.include? ":"
		if !date.include? "000000000000"
			year = date[0,4]
			dates_to_check << year
			page = Nokogiri::HTML(open("http://web.archive.org/web/#{year}0600000000*/http://#{domain}"))   
			snapshots = page.css('div.pop')
			snapshots_counter += snapshots.size
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
