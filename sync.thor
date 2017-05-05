require 'jira-ruby'
require 'byebug'

class Sync < Thor
  desc "example", "an example task"
  def example
    puts "Hello, World!"
  end

  desc "boards", "sync list of boards"
  def boards
    puts "Sync boards"
    client = build_client
    rapid_views = client.RapidView.all
    rapid_views.each do |rapid_view|
      puts "#{rapid_view.name} (#{rapid_view.id})"
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
end
