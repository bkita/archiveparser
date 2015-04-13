# Gem and other dependencies
require 'nokogiri'
require 'open-uri'

# Package files
require File.dirname(__FILE__) + '/archive_parser.rb'

Archive.read_domains_from_file
Archive.archive_data

# Domains to check with WHOIS
Archive.domains_whois
