class WhoisParser

  @whois = ''
  @whois_arr = []
  @billing_period_finished = false
  @created = ''
  @expiration = ''       

def self.check_whois(domain)
      @whois = ask_whois_for(domain)
      @whois_arr = @whois.split(/\n/)
      self.take_a_break
  end

  def self.ask_whois_for(domain)
    `whois '#{domain}'`
  end

  def self.take_a_break
    random_number = Random.rand(2...5)
    puts "waiting for " + random_number.to_s
    sleep random_number
  end

  def self.is_billing_period_finished
    if @whois.include? 'billing period had finished'
      @billing_period_finished = true
    end
  end

  def self.created_date
    @whois_arr.each do |line|
      if line.include?('created:               ')
        @created = line
        @created.gsub!('created:', '').gsub!(/\s+/,'')
        @created = @created[0,10]
      end
    end
    @created
  end

  def self.expiration_date
    @whois_arr.each do |line|
      if line.include?('expiration date:       ')
        @expiration = line
        @expiration.gsub!('expiration date:', '').gsub!(/\s+/,'')
        @expiration = @expiration[0,10]
      end
    end
  end

  def self.setup
    self.is_billing_period_finished
    self.created_date
    self.expiration_date
  end

  def self.cleanup
    @whois = ''
    @billing_period_finished = false
    @created = ''
    @expiration = ''
    @whois_arr.clear
  end

  def self.whois_details(domains)
    domains.each do |domain|
      puts domain
      self.check_whois(domain)
      self.setup

      puts @billing_period_finished
      puts @created
      puts @expiration      

      self.cleanup
    end
  end

end