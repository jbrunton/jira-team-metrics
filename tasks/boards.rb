require 'byebug'
require 'yaml/store'

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
      rapid_views = client.get_rapid_boards
      @store.update(rapid_views)
      puts "Synced #{rapid_views.count} boards"
    end
  end

  desc "list", "list all boards"
  def list
    say "Listing boards:", :bold
    rows = @store.all.map{ |board| [board.id, board.name] }
    print_table(rows, indent: 2)
  end

  desc "search", "search boards"
  def search(regex)
    say "Boards matching #{regex}:", :bold

    r = Regexp.new(regex)
    results = @store.all
      .select{ |board| r.match(board.name) }
      .map{ |board| [board.id, board.name] }

    print_table(results, indent: 2)
  end
end
