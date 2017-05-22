require 'byebug'
require 'yaml/store'
require 'ruby-progressbar'
require 'time'
require 'descriptive_statistics'
require 'erb'

class Board < JiraTask
  desc "issue", "issue details"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :transitions, :desc => "show transitions"
  def issue(key)
    board_id = get_board_id(options)
    board = boards_store.get_board(board_id)

    issue = IssueDecorator.new(board.issues.find{ |i| i.key == key}, nil, nil)

    output_table("Details for #{issue.key}:", issue.overview_table)

    if options[:transitions]
      output_table("Transitions:", issue.transitions_table)
    end
  end

  desc "summary", "summarize work"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :ct_between, :desc => "compute cycle time between these states"
  def summary
    board = load_board(options)
    output_table("Summary for #{board.name}:", board.summary_table)
  end

  desc "issues", "list completed issues"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :ct_between, :desc => "compute cycle time between these states"
  def issues
    board = load_board(options)
    output_table("Issues for #{board.name}:", board.issues_table)
  end

  desc "sync", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :since, :desc => "date to sync changes since"
  def sync
    board_id = get_board_id(options)
    status = options[:status]
    if status
        last_updated = boards_store.board_last_updated(board_id) || "Never"
        puts "Last updated: #{last_updated}"
    else
      board = boards_store.get_board(board_id)
      if options[:since]
        if /\d{4}-\d{2}-\d{2}/.match(options[:since])
          since_date = Time.parse(options[:since])
        else
          raise "'since' option must be in the format YYYY-MM-DD"
        end
      else
        since_date = Time.now - (180 * 60 * 60 * 24)
      end
      issues = fetch_issues_for(board, since_date)
      boards_store.update_board(board_id, issues, since_date)
      puts "Synced board"
    end
  end

  desc "exclude", "exclude given issues"
  def exclude(issue_keys)
    board_id = get_board_id(options)
    domain_name = config.get('defaults.domain')
    path = "exclusions.domains.#{domain_name}.boards.board/#{board_id}"
    exclusions = config.get(path)
    config.set(path, exclusions + ' ' + issue_keys)
  end

  desc "exclusions", "print excluded issues"
  method_option :clear, :desc => "clear exclusions"
  def exclusions
    board_id = get_board_id(options)
    domain_name = config.get('defaults.domain')
    path = "exclusions.domains.#{domain_name}.boards.board/#{board_id}"

    if options[:clear]
      config.set(path, '')
    else
      exclusions = config.get(path)
      say 'Excluded issues:', :bold
      say "  #{exclusions}"
    end
  end

private
  def output_table(description, table)
    say description, :bold
    print_table(table.marshal_for_terminal, indent: 2)
  end

  def fetch_issues_for(board, since_date)
    progressbar = ProgressBar.create
    progressbar.progress = 0
    start_time = Time.now
    statuses = domains_store.find(config.get('defaults.domain'))['statuses']
    query = QueryBuilder.new(board.query)
      .and("status changed AFTER '#{since_date.strftime('%Y-%m-%d')}'")
      .query
    issues = client.search_issues(query: query, statuses: statuses) do |progress|
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
    BoardDecorator.new(boards_store.get_board(board_id), ct_states[0], ct_states[1])
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
