class Archive

 def initialize
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

  @snap_from = 5
  @snap_to = 8

  @archive_summary = Hash.new 
  @domains_archive = []
end

def get_full_archive(domains)
  domains.each do |domain|
    begin

     setup(domain)
     if ((@year_counter.between?(@snap_from, @snap_to)) && (@ratio > 7))
      snapshots_counter(domain)
      archive_summary(domain)
     end

   rescue Exception => e
    if e.message == '404 Not Found' 
    end
  end
    cleanup
  end
  @archive_summary
end

def get_short_archive(domains)
  domains.each do |domain|
    begin

     setup(domain)
     if (@year_counter.between?(@snap_from, @snap_to)) && (@ratio > 9)
      puts domain
      @domains_archive << domain
     end

   rescue Exception => e
    if e.message == '404 Not Found' 
    end
  end
    cleanup
  end
  @domains_archive
end

private
def read_archive_page_content(domain)
 @archive_page_content = Nokogiri::HTML(open("#{@archive_web_url}#{domain}"))
end

def years_with_snapshot
 @years_with_snapshot = @archive_page_content.at_xpath('//*[@id="sparklineImgId"]/@src').to_s.split("_")
end

def saved_times_counter
 @saved_times_counter = @archive_page_content.css("div#wbMeta p[2] strong").text
 @saved_times_counter = @saved_times_counter.delete!(" times")
end

def start_end_year
 start_date = Time.parse(@archive_page_content.css("div#wbMeta p[2] a[2]").text)
 start_year = start_date.strftime("%Y ")
 @start_year  = start_year.delete!(" ")

 end_date  = Time.parse(@archive_page_content.css("div#wbMeta p[2] a[3]").text)
 end_year = end_date.strftime("%Y ")
 @end_year  = end_year.delete!(" ")

 return @start_year, @end_year
end

def year_counter
 if @saved_times_counter.to_i > 1
  @year_counter = (@end_year.to_i - @start_year.to_i) + 1
else
  @year_counter = 1
end
end

def ratio
 @ratio = @saved_times_counter.to_i / @year_counter
end

def setup(domain)
  read_archive_page_content(domain)
  years_with_snapshot
  saved_times_counter
  start_end_year
  year_counter
  ratio
end

def cleanup
  @end_year = ''
  @start_year = ''
  @saved_times_counter = ''
  @year_counter = ''
  @ratio = ''
  @snapshots_summary = ''
end

def snapshots_counter(domain)
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
  @snapshots_summary
end

def archive_summary(domain)
  @archive_summary[domain] = domain + ";" + @start_year + ";" + @end_year + ";" + @year_counter.to_s + ";" + @saved_times_counter + ";" + @ratio.to_s + ";" + @snapshots_summary
end

end
