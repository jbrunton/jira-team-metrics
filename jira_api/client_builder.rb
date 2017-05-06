class ClientBuilder
  def build
    options = {
      :username     => @username,
      :password     => @password,
      :site         => 'https://jira.zipcar.com/',
      :context_path => '',
      :auth_type    => :basic
    }

    JIRA::Client.new(options)
  end

  def prompt
    config_store.transaction do
      @username = config_store['username']
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

private
  def config_store
    @store ||= YAML::Store.new('data/config.yml')
  end
end
