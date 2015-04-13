# Gem and other dependencies
require 'nokogiri'
require 'open-uri'

# Package files
require File.dirname(__FILE__) + '/archive_parser.rb'
require File.dirname(__FILE__) + '/whois_parser.rb'

#Archive.read_domains_from_file
#Archive.archive_data

# Domains to check with WHOIS
#domains = Archive.domains_whois

domains = []
domains << "1kredythipoteczny.pl"
domains << "1noc.pl"

WhoisParser.whois_details(domains)
