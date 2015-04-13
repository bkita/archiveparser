class Archive

  @domains = []
  @input_file = 'domains.txt'
  @archive_page_content = ''
  @archive_web_url = "http://web.archive.org/web/*/"

  @end_year = ''
  @start_year = ''
  @saved_times_counter = ''
  @year_counter = ''
  @ratio = ''

  @years_with_snapshot = []
  @snapshots = []
  @snapshots_summary = ''
  @snapshot_page_content = ""

  @domains_whois = []

  def self.read_domains_from_file
  	file = File.new("#{@input_file}", 'r')
	file.each_line do |line| 
	  line.delete!("\n")
      line.gsub!(/\s/,',')
      @domains << line 	
  	end
  end

  def self.read_archive_page_content(domain)
  	@archive_page_content = Nokogiri::HTML(open("#{@archive_web_url}#{domain}"))
  end

  def self.years_with_snapshot
  	@years_with_snapshot = @archive_page_content.at_xpath('//*[@id="sparklineImgId"]/@src').to_s.split("_")
  end

  def self.saved_times_counter
  	@saved_times_counter = @archive_page_content.css("div#wbMeta p[2] strong").text
	  @saved_times_counter = @saved_times_counter.delete!(" times")
  end

  def self.start_end_year
  	start_date = Time.parse(@archive_page_content.css("div#wbMeta p[2] a[2]").text)
	  start_year = start_date.strftime("%Y ")
	  @start_year  = start_year.delete!(" ")
		
	  end_date  = Time.parse(@archive_page_content.css("div#wbMeta p[2] a[3]").text)
	  end_year = end_date.strftime("%Y ")
	  @end_year  = end_year.delete!(" ")

	  return @start_year, @end_year
  end

  def self.year_counter
  	if @saved_times_counter.to_i > 1
  		@year_counter = (@end_year.to_i - @start_year.to_i) + 1
  	else
  		@year_counter = 1
  	end
  end

  def self.ratio
  	@ratio = @saved_times_counter.to_i / @year_counter
  end

  def self.setup(domain)
		self.read_archive_page_content(domain)
		self.years_with_snapshot
		self.saved_times_counter
		self.start_end_year
		self.year_counter
		self.ratio
  end

  def self.cleanup
    @end_year = ''
    @start_year = ''
    @saved_times_counter = ''
    @year_counter = ''
    @ratio = ''
    @snapshots_summary = ''
  end

  def self.snapshots_counter(domain)
    if @year_counter.between?(5, 8)
        @years_with_snapshot.each do |snapshot|
          if snapshot.include? ":"
            if !snapshot.include? "000000000000"
              snapshot_year = snapshot[0,4]
              @snapshot_page_content = Nokogiri::HTML(open("http://web.archive.org/web/#{snapshot_year}0600000000*/http://#{domain}"))   
              @snapshots = @snapshot_page_content.css('div.pop')
              @snapshots_summary += snapshot_year.to_s + "[" + @snapshots.size.to_s + "]" + " "
            else
              if snapshot[0,4].to_i >= @start_year.to_i
                snapshot_year = snapshot[0,4]
                @snapshots_summary += snapshot_year.to_s + "[0]" + " "
              end
            end
          end
        end
    end
    @snapshots_summary
  end

  def self.show_archive_summary(domain)
    if @year_counter.between?(5, 8)

      @domains_whois << domain

      #puts "Domain: " + domain
      #puts "Start year: " + @start_year
      #puts "End year: " + @end_year
      #puts "Year counter: " + @year_counter.to_s
      #puts "Saved times: " + @saved_times_counter
      #puts "Ratio: " + @ratio.to_s
      #puts "Snapshots counter summary: " + @snapshots_summary
    end
  end

  def self.domains_whois
    puts "Domain to check with whois :"
    @domains_whois.each do |domain_whois|
      puts domain_whois
    end
  end

  def self.archive_data
  	@domains.each do |domain|
      begin
  	   
       self.setup(domain)
       self.snapshots_counter(domain)
       self.show_archive_summary(domain)

      rescue Exception => e
        if e.message == '404 Not Found'
        end
      end
  	  
      self.cleanup
  	end
  end

end