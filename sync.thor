require 'jira-ruby'
require 'byebug'
require 'yaml/store'

class Sync < Thor
  desc "example", "an example task"
  def example
    puts "Hello, World!"
  end

  desc "boards", "sync list of boards"
  def boards
    puts "Sync boards"
    client = build_client
    rapid_views = client.RapidView.all.map do |rapid_view|
      [rapid_view.id, rapid_view.name]
    end.to_h
    boards_store.transaction do
      boards_store['boards'] = rapid_views
      boards_store['last_updated'] = Time.now
    end
  end

  def build_client
    credentials = prompt_for_credentials

    options = {
      :username     => credentials[:username],
      :password     => credentials[:password],
      :site         => 'https://jira.zipcar.com/',
      :context_path => '',
      :auth_type    => :basic
    }

    JIRA::Client.new(options)
  end

  def prompt_for_credentials
    print "JIRA username: "
    username = STDIN.gets.chomp

    print "JIRA password: "
    password = STDIN.noecho(&:gets).chomp

    # otherwise we start printing on the same line as our input later on..
    puts

    { username: username, password: password }
  end

  def boards_store
    @store ||= YAML::Store.new('boards.yml')
  end
end
