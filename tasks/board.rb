require 'jira-ruby'
require 'byebug'
require 'yaml/store'
require './jira_api/client_builder'

class Board < Thor
  def initialize(*args)
    super
    @store = Store::Boards.instance
  end

  desc "sync ID", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync(id)
    status = options[:status]
    if status
        last_updated = @store.board_last_updated(id) || "Never"
        puts "Last updated: #{last_updated}"
    else
      client = ClientBuilder.new.prompt.build
      rapid_view = client.RapidView.find(id)
      # rapid_views = client.RapidView.all.map do |rapid_view|
      #   [rapid_view.id, rapid_view.name]
      # end.to_h
      @store.update_board(id)
      puts "Synced board"
    end
  end
end
