require 'byebug'
require 'yaml/store'
require './tasks/jira_task'
require 'ruby-progressbar'

class Board < JiraTask
  def initialize(*args)
    super
    @store = Store::Boards.instance
  end

  desc "summary ID", "summarize work"
  def summary(id)
    id = id.to_i
    board = @store.get_board(id)

    issues_by_type = board.issues.group_by { |issue| issue.issue_type }

    labels = ['Issue Type']
    counts = ['Count']
    issues_by_type.each do |type, issues|
      labels << type
      counts << issues.count
    end
    labels << 'TOTAL'
    counts << board.issues.count
    say "Summary for #{board.name}:", :bold
    print_table([labels, counts].transpose, indent: 2)
  end

  desc "sync ID", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  def sync(id)
    id = id.to_i
    status = options[:status]
    if status
        last_updated = @store.board_last_updated(id) || "Never"
        puts "Last updated: #{last_updated}"
    else
      board = @store.get_board(id)
      issues = fetch_issues_for(board)
      @store.update_board(id, issues)
      puts "Synced board"
    end
  end

private
  def fetch_issues_for(board)
    progressbar = ProgressBar.create
    progressbar.progress = 0
    start_time = Time.now
    statuses = domains_store.find(config.get('domain'))['statuses']
    issues = client.search_issues(query: board.query, statuses: statuses) do |progress|
      progressbar.progress = progress
    end
    end_time = Time.now
    puts "Elapsed time: #{(end_time - start_time).to_i}s"
    issues
  end
end
