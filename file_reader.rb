class FileReader

  @input_file = 'domains.txt'
  @domains = []

  def self.read_domains_from_file
  	file = File.new("#{@input_file}", 'r')
	file.each_line do |line| 
	  line.delete!("\n")
      line.gsub!(/\s/,',')
      @domains << line 	
  	end
  	@domains
  end

end