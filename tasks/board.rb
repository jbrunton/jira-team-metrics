require 'byebug'
require 'yaml/store'
require 'ruby-progressbar'
require 'time'
require 'descriptive_statistics'
require 'erb'

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
    board = load_board(options)

    say "Summary for #{board.name}:", :bold
    print_table(board.summary_table.marshal_for_terminal, indent: 2)
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
    board = load_board(options)

    say "Issues for #{board.name}:", :bold
    print_table(board.issues_table.marshal_for_terminal, indent: 2)
  end

  desc "report", "generate html report"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :ct_between, :desc => "compute cycle time between these states"
  def report
    @board = load_board(options)

    template 'board_index.html.erb', board_summary_path(@board), force: true
    template 'board_issues.html.erb', board_issues_path(@board), force: true
  end

private
  def source_paths
    ['templates']
  end

  def board_summary_path(board)
    "reports/#{board.id}/index.html"
  end

  def board_issues_path(board)
    "reports/#{board.id}/issues.html"
  end

  def board_summary_url(board)
    File.join(destination_root, board_summary_path(board))
  end

  def board_issues_url(board)
    File.join(destination_root, board_issues_path(board))
  end

  def print_table(table)
    table_template = ERB.new(File.read("templates/table.html.erb"))
    table_template.result(table.get_binding).to_s
  end

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

  def load_board(options)
    board_id = get_board_id(options)
    ct_states = options[:ct_between].split(',').map{|s| s.strip } if options[:ct_between]
    ct_states ||= {}
    BoardDecorator.new(@store.get_board(board_id), ct_states[0], ct_states[1])
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
end
