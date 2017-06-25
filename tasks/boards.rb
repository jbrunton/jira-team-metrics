require 'byebug'
require 'yaml/store'

class Boards < JiraTask
  desc "sync", "sync list of boards"
  method_option :status, :aliases => "-s", :desc => "status"
  method_option :domain, :aliases => "-d", :desc => "domain name"
  def sync
    status = options[:status]
    domain = get_domain(options)
    if status
      last_synced = domain.last_synced || "Never"
      puts "Last synced: #{last_synced}"
    else
      boards = client.get_rapid_boards
      boards.each do |b|
        domain.boards.create(b.to_h)
      end
      puts "Synced #{boards.count} boards"
    end
  end

  desc "list", "list all boards"
  method_option :domain, :aliases => "-d", :desc => "domain name"
  def list
    say "Listing boards:", :bold
    rows = get_domain(options).boards.all.map{ |board| [board.id, board.name] }
    print_table(rows, indent: 2)
  end

  desc "search", "search boards"
  def search(query)
    say "Boards matching #{query}:", :bold

    results = get_domain(options).boards.where('name like ?', "%#{query}%")
      .map{ |board| [board.id, board.name] }

    print_table(results, indent: 2)
  end
end
