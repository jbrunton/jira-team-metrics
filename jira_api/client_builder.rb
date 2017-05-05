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
    print "JIRA username: "
    @username = STDIN.gets.chomp

    print "JIRA password: "
    @password = STDIN.noecho(&:gets).chomp

    # otherwise we start printing on the same line as our input later on..
    puts

    self
  end
end
