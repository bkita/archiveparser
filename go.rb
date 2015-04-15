# Gem and other dependencies
require 'nokogiri'
require 'open-uri'

# Package files
require File.dirname(__FILE__) + '/archive_parser.rb'
require File.dirname(__FILE__) + '/whois_parser.rb'
require File.dirname(__FILE__) + '/file_reader.rb'

domains = FileReader.read_domains_from_file
archive = Archive.new
whois = WhoisParser.new

archive_domains = archive.get_archive(domains)

archive_domains.each do |domain, archive_summary|
	puts archive_summary
end

whois_domains = whois.get_whois(archive_domains)
whois_domains.each do |domain, whois_summary|
	puts whois_summary
end


