class WhoisParser

  # POPRAWIC VALIDACJE ROKU TAJ JAK W ARCHIVE
  def initialize
    @whois = ''
    @whois_arr = []
    @billing_period_finished = false
    @created = ''
    @expiration = ''
    @domain_age = ''
    @option = false
    @whois_summary = Hash.new 
  end


  def get_whois(domains)
    domains.each do |domain, domain_value|
      check_whois(domain)
      setup(domain)
      cleanup
    end
    @whois_summary
  end    

  private
  def check_whois(domain)
    @whois = ask_whois_for(domain)
    @whois_arr = @whois.split(/\n/)
    take_a_break
  end

  def ask_whois_for(domain)
    `whois '#{domain}'`
  end

  def take_a_break
    random_number = Random.rand(2...5)
    sleep random_number
  end

  def is_billing_period_finished
    if @whois.include? 'billing period had finished'
      @billing_period_finished = true
    end
  end

  def is_option_created
    if @whois.include? 'option expiration date:       '
      @option = true
    end
  end

  def created_date
    @whois_arr.each do |line|
      if line.include?('created:               ')
        @created = line
        @created.gsub!('created:', '').gsub!(/\s+/,'')
        @created = @created[0,4]
      end
    end
    @created
  end

  def expiration_date
    @whois_arr.each do |line|
      if line.include?('expiration date:       ')
        @expiration = line
        @expiration.gsub!('expiration date:', '').gsub!(/\s+/,'')
        @expiration = @expiration[0,4]
      end
    end
  end

  def domain_age
    @domain_age = @expiration.to_i - @created.to_i
  end

  def setup(domain)
    is_billing_period_finished
    is_option_created

    if @billing_period_finished == true && @option == false
      created_date
      expiration_date
      domain_age
      @whois_summary[domain] = domain + ";" + @billing_period_finished.to_s + ";" + @option.to_s + ";" + @created.to_s + ";" + @expiration.to_s  + ";" + @domain_age.to_s
    end
  end

  def cleanup
    @whois = ''
    @billing_period_finished = false
    @option = false
    @created = ''
    @expiration = ''
    @whois_arr.clear
  end

end