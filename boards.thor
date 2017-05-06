require 'jira-ruby'
require 'byebug'
require 'yaml/store'
require './jira_api/client_builder'

class Boards < Thor
  desc "sync", "sync list of boards"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync
    status = options[:status]
    if status
      boards_store.transaction do
        last_updated = boards_store['last_updated'] || "Never"
        puts "Last updated: #{last_updated}"
      end
    else
      client = ClientBuilder.new.config(Store::Config.instance).prompt.build
      rapid_views = client.RapidView.all.map do |rapid_view|
        [rapid_view.id, rapid_view.name]
      end.to_h
      boards_store.transaction do
        boards_store['boards'] = rapid_views
        boards_store['last_updated'] = Time.now
      end
      puts "Synced #{rapid_views.count} boards"
    end
  end

  desc "list", "list all boards"
  def list
    boards_store.transaction do
      boards_store['boards'].each do |id, name|
        puts "#{name} (#{id})"
      end
    end
  end

  desc "search", "search boards"
  def search(regex)
    r = Regexp.new(regex)
    boards_store.transaction do
      boards_store['boards'].each do |id, name|
        if r.match?(name)
          puts "#{name} (#{id})"
        end
      end
    end
  end

private

  def boards_store
    @store ||= YAML::Store.new('data/boards.yml')
  end
end
