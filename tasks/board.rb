require 'byebug'
require 'yaml/store'
require 'ruby-progressbar'
require 'time'
require 'descriptive_statistics'
require 'erb'

class BoardTask < JiraTask
  namespace :board

  desc "sync", "sync board"
  method_option :status, :aliases => "-s", :desc => "status"
  method_option :board_id, :desc => "board id", :type => :numeric
  method_option :since, :desc => "date to sync changes from"
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
          sync_from = Time.parse(options[:since])
        else
          raise "'since' option must be in the format YYYY-MM-DD"
        end
      else
        sync_from = Time.now - (180 * 60 * 60 * 24)
      end
      issues = fetch_issues_for(board, sync_from)
      boards_store.update_board(board_id, issues, sync_from)
      puts "Synced board"
    end
  end

  desc "exclude", "exclude given issues"
  def exclude(issue_keys)
    board_id = get_board_id(options)
    domain_name = config.get('defaults.domain')
    path = "exclusions.domains.#{domain_name}.boards.board/#{board_id}"
    exclusions = config.get(path) || ''
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
  def fetch_issues_for(board, since_date)
    statuses = domains_store.find(config.get('defaults.domain'))['statuses']
    query = QueryBuilder.new(board.query)
      .and("status changed AFTER '#{since_date.strftime('%Y-%m-%d')}'")
      .query
    issues = client.search_issues(query: query, statuses: statuses) do |progress|
      @progressbar ||= ProgressBar.create(:format => '%a %B %p%% %t')
      @progressbar.progress = progress
    end
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
end
