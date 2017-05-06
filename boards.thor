require 'jira-ruby'
require 'byebug'
require 'yaml/store'
require './jira_api/client_builder'
require './store/boards'

class Boards < Thor
  def initialize(*args)
    super
    @store = Store::Boards.instance
  end

  desc "sync", "sync list of boards"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync
    status = options[:status]
    if status
      last_updated = @store.last_updated || "Never"
      puts "Last updated: #{last_updated}"
    else
      client = ClientBuilder.new.config(Store::Config.instance).prompt.build
      rapid_views = client.RapidView.all.map do |rapid_view|
        [rapid_view.id, rapid_view.name]
      end.to_h
      @store.update(rapid_views)
      puts "Synced #{rapid_views.count} boards"
    end
  end

  desc "list", "list all boards"
  def list
    @store.boards.each do |id, name|
      puts "#{name} (#{id})"
    end
  end

  desc "search", "search boards"
  def search(regex)
    r = Regexp.new(regex)
    @store.boards.each do |id, name|
      if r.match?(name)
        puts "#{name} (#{id})"
      end
    end
  end

private

  def boards_store
    @store ||= YAML::Store.new('data/boards.yml')
  end
end
