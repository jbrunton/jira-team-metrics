require 'byebug'
require 'yaml/store'

class Boards < JiraTask
  desc "sync", "sync list of boards"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync
    status = options[:status]
    if status
      last_updated = boards_store.last_updated || "Never"
      puts "Last updated: #{last_updated}"
    else
      rapid_views = client.get_rapid_boards
      boards_store.update(rapid_views)
      puts "Synced #{rapid_views.count} boards"
    end
  end

  desc "list", "list all boards"
  def list
    say "Listing boards:", :bold
    rows = boards_store.all.map{ |board| [board.id, board.name, board.last_updated] }
    print_table(rows, indent: 2)
  end

  desc "search", "search boards"
  def search(query)
    say "Boards matching #{query}:", :bold

    results = boards_store.search(query)
      .map{ |board| [board.id, board.name] }

    print_table(results, indent: 2)
  end
end
