require 'jira-ruby'
require 'byebug'
require 'yaml/store'
require './jira_api/client_builder'

class Board < Thor
  desc "sync ID", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync(id)
    store = board_store(id)

    status = options[:status]
    if status
      store.transaction do
        last_updated = store['last_updated'] || "Never"
        puts "Last updated: #{last_updated}"
      end
    else
      client = ClientBuilder.new.prompt.build
      rapid_view = client.RapidView.find(id)
      # rapid_views = client.RapidView.all.map do |rapid_view|
      #   [rapid_view.id, rapid_view.name]
      # end.to_h
      store.transaction do
        #boards_store['boards'] = rapid_views
        store['last_updated'] = Time.now
      end
      puts "Synced board"
    end
  end

private

  def board_store(id)
    YAML::Store.new("data/boards/#{id}.yml")
  end
end
