class JiraTeamMetrics::JiraClientBuilder
  def build
    credentials = { username: @username, password: @password }
    JiraTeamMetrics::JiraClient.new(@url, credentials)
  end

  def domains_store(domains_store)
    @domains_store = domains_store
    self
  end

  def config(config)
    @config = config
    self
  end

  def prompt
    unless @config.nil?
      domain_name = @config.get('defaults.domain')
      @username = @config.get("defaults.domains.#{domain_name}.username")
      @url = @domains_store.find(domain_name)['url'] unless @domains_store.nil?
    end

    if @url.nil?
      print "JIRA domain: "
      @url = STDIN.gets.chomp
    end

    if @username.nil?
      print "JIRA username: "
      @username = STDIN.gets.chomp
      password_prompt = "JIRA password: "
    else
      password_prompt = "JIRA password (for user #{@username}): "
    end

    puts password_prompt
    @password = STDIN.noecho(&:gets).chomp

    # otherwise we start printing on the same line as our input later on..
    puts

    self
  end

  def url(url)
    @url = url
    self
  end
end

