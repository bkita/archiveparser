require 'rubygems'
require 'nokogiri'
require 'open-uri'

start_date = 2005
end_date = 2014
domain = "bobosklep.pl"
snapshots_counter = 0

(start_date..end_date).each do |year|
	page = Nokogiri::HTML(open("http://web.archive.org/web/#{year}0600000000*/http://#{domain}"))   
	snapshots = page.css('div.pop')
	ßsnapshots_counter += snapshots.size
	puts year.to_s + ' - ' + snapshots.size.to_s
end

puts snapshots_counter


