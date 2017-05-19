require 'byebug'
require 'yaml/store'
require 'ruby-progressbar'
require 'time'
require 'descriptive_statistics'

class Board < JiraTask
  def initialize(*args)
    super
    @store = Store::Boards.instance
  end

  desc "issue", "issue details"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :transitions, :desc => "show transitions"
  def issue(key)
    board_id = get_board_id(options)
    board = @store.get_board(board_id)

    issue = board.issues.find{ |i| i.key == key}

    say "Details for #{issue.key}:", :bold
    rows = [
      ['Key', issue.key],
      ['Summary', issue.summary],
      ['Issue Type', issue.issue_type],
      ['Started', issue.started.strftime('%d %b %Y')],
      ['Completed', issue.completed.strftime('%d %b %Y')]
    ]

    print_table(rows, indent: 2)

    if options[:transitions]
      say "Transitions:", :bold
      rows = issue.transitions.map do |t|
        date = Time.parse(t['date']).strftime('%d %b %Y %H:%M')
        [date, t['status']]
      end
      print_table(rows, indent: 2)
    end
  end

  desc "summary", "summarize work"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :ct_between, :desc => "compute cycle time between these states"
  def summary
    board_id = get_board_id(options)
    ct_states = options[:ct_between].split(',').map{|s| s.strip } if options[:ct_between]
    board = @store.get_board(board_id)

    rows = summary_for(board, ct_states)

    say "Summary for #{board.name}:", :bold
    print_table(rows, indent: 2)
  end

  desc "sync", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  method_option :board_id, :desc => "board id", :type => :numeric
  def sync
    board_id = get_board_id(options)
    status = options[:status]
    if status
        last_updated = @store.board_last_updated(board_id) || "Never"
        puts "Last updated: #{last_updated}"
    else
      board = @store.get_board(board_id)
      issues = fetch_issues_for(board)
      @store.update_board(board_id, issues)
      puts "Synced board"
    end
  end

  desc "issues", "list completed issues"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :ct_between, :desc => "compute cycle time between these states"
  def issues
    board_id = get_board_id(options)
    ct_states = options[:ct_between].split(',').map{|s| s.strip } if options[:ct_between]
    board = @store.get_board(board_id)
    rows = completed_issues_for(board, ct_states)
    print_table rows
  end

  desc "report", "generate html report"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :ct_between, :desc => "compute cycle time between these states"
  def report
    board_id = get_board_id(options)
    ct_states = options[:ct_between].split(',').map{|s| s.strip } if options[:ct_between]
    board = @store.get_board(board_id)
    rows = completed_issues_for(board, ct_states)

    create_file "reports/#{board_id}/index.html", force: true do
      "<h1>#{board.name}</h1>"
    end
  end

private
  def fetch_issues_for(board)
    progressbar = ProgressBar.create
    progressbar.progress = 0
    start_time = Time.now
    statuses = domains_store.find(config.get('defaults.domain'))['statuses']
    issues = client.search_issues(query: board.query, statuses: statuses) do |progress|
      progressbar.progress = progress
    end
    end_time = Time.now
    puts "Elapsed time: #{(end_time - start_time).to_i}s"
    issues
  end

  def get_board_id(options)
    board_id = options[:board_id]
    domain_name = config.get('defaults.domain')
    board_id = config.get("defaults.domains.#{domain_name}.board_id").to_i if board_id.nil?
    if board_id.nil?
      say 'board_id required'
      exit
    else
      say "Using board_id #{board_id} from config"
    end
    board_id
  end

  def summary_for(board, ct_states)
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
      cycle_times = issues.map do |i|
        if ct_states
          cycle_time = i.cycle_time_between(ct_states[0], ct_states[1])
        else
          cycle_time = i.cycle_time
        end
        cycle_time
      end
      mean_cycle_times << ('%.2fd' % cycle_times.mean)
      median_cycle_times << ('%.2fd' % cycle_times.median)
      stddev_cycle_times << ('%.2fd' % cycle_times.standard_deviation)
    end
    labels << 'TOTAL'
    counts << board.issues.count
    mean_cycle_times << ''
    median_cycle_times << ''
    stddev_cycle_times << ''

    [labels, counts, mean_cycle_times, median_cycle_times, stddev_cycle_times].transpose
  end

  def completed_issues_for(board, ct_states)
    completed_issues = board.issues.select{ |i| i.completed && i.started }
    rows = [['KEY', 'TYPE', 'SUMMARY', 'COMPLETED', 'CYCLE TIME', '']]
    data = completed_issues.map do |i|
      if ct_states
        started = i.started(ct_states[0])
        completed = i.completed(ct_states[1])
        cycle_time = i.cycle_time_between(ct_states[0], ct_states[1])
      else
        started = i.started
        completed = i.completed
        cycle_time = i.cycle_time
      end
      [i, started, completed, cycle_time]
    end
    max_cycle_time = data.map{ |x| x.last }.compact.max
    data.each do |x|
      i = x[0]
      completed = x[2]
      cycle_time = x[3]
      indicator = cycle_time ? ("-" * (cycle_time / max_cycle_time * 10).to_i) : ""
      rows << [i.key, i.issue_type, i.summary, completed.strftime('%d %b %Y'), cycle_time ? ('%.2fd' % cycle_time) : '', indicator]
    end
  end
end
