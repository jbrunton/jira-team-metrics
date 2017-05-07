require './models/jira/client'

module Jira
  class ClientBuilder
    def build
      credentials = { username: @username, password: @password }
      Jira::Client.new(@url, credentials)
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
        @username = @config.get('username')
        @url = @domains_store.find(@config.get('domain'))['url'] unless @domains_store.nil?
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

  private
    def config_store
      @store ||= YAML::Store.new('data/config.yml')
    end
  end
end
