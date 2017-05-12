require 'byebug'
require 'yaml/store'
require './tasks/jira_task'
require 'ruby-progressbar'
require 'time'
require 'descriptive_statistics'

class Board < JiraTask
  def initialize(*args)
    super
    @store = Store::Boards.instance
  end

  desc "summary", "summarize work"
  method_option :board_id, :desc => "board id", :type => :numeric
  def summary
    board_id = get_board_id(options)
    board = @store.get_board(board_id)

    completed_issues = board.issues.select{ |i| i.completed && i.started }
    issues_by_type = completed_issues.group_by { |issue| issue.issue_type }

    labels = ['Issue Type']
    counts = ['Count']
    mean_cycle_times = ['CT (mean)']
    median_cycle_times = ['(median)']
    stddev_cycle_times = ['(stddev)']
    issues_by_type.each do |type, issues|
      labels << type
      counts << issues.count
      cycle_times = issues.map{ |i| i.cycle_time }
      mean_cycle_times << ('%.2fd' % cycle_times.mean)
      median_cycle_times << ('%.2fd' % cycle_times.median)
      stddev_cycle_times << ('%.2fd' % cycle_times.standard_deviation)
    end
    labels << 'TOTAL'
    counts << board.issues.count
    mean_cycle_times << ''
    median_cycle_times << ''
    stddev_cycle_times << ''
    say "Summary for #{board.name}:", :bold
    print_table([labels, counts, mean_cycle_times, median_cycle_times, stddev_cycle_times].transpose, indent: 2)
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

  desc "issues", "list completed issues"
  method_option :board_id, :desc => "board id", :type => :numeric
  def issues
    board_id = get_board_id(options)
    board = @store.get_board(board_id)
    completed_issues = board.issues.select{ |i| i.completed && i.started }
    rows = [['KEY', 'TYPE', 'SUMMARY', 'COMPLETED', 'CYCLE TIME', '']]
    data = completed_issues.map do |i|
      [i, i.started_time, i.completed_time, i.cycle_time]
    end
    max_cycle_time = data.map{ |x| x.last }.max
    data.each do |x|
      i = x[0]
      completed = x[2]
      cycle_time = x[3]
      indicator = "-" * (cycle_time / max_cycle_time * 10).to_i
      rows << [i.key, i.issue_type, i.summary, completed.strftime('%d %b %Y'), '%.2fd' % cycle_time, indicator]
    end
    print_table rows
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

  def get_board_id(options)
    board_id = options[:board_id]
    board_id = config.get('board_id').to_i if board_id.nil?
    if board_id.nil?
      say 'board_id required'
      exit
    else
      say "Using board_id #{board_id} from config"
    end
    board_id
  end
end
