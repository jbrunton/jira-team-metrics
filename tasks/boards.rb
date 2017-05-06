require 'byebug'
require 'yaml/store'
require './tasks/jira_task'
require './store/boards'

class Boards < JiraTask
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
      rapid_views = client.get_rapid_boards.map do |rapid_view|
        [rapid_view.id, {'name' => rapid_view.name, 'query' => rapid_view.query}]
      end.to_h
      @store.update(rapid_views)
      puts "Synced #{rapid_views.count} boards"
    end
  end

  desc "list", "list all boards"
  def list
    @store.boards.each do |id, board|
      puts "#{board['name']} (#{id})"
    end
  end

  desc "search", "search boards"
  def search(regex)
    r = Regexp.new(regex)
    @store.boards.each do |id, board|
      name = board['name']
      if r.match?(name)
        puts "#{name} (#{id})"
      end
    end
  end
end
