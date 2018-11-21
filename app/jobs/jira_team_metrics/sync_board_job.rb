class JiraTeamMetrics::SyncBoardJob < ApplicationJob
  queue_as :default

  def perform(jira_id, domain, credentials, months)
    begin
      board = find_target_board(jira_id, domain)
      @notifier = JiraTeamMetrics::StatusNotifier.new(board, "syncing #{board.name}")

      sync_issues(board, credentials, months)
      create_filters(board, credentials)
      build_reports(board)
      activate(board)
      @notifier.notify_complete
    ensure
      end_sync(domain) if domain.active?
    end
  end

  def build_reports(board)
    board.projects.each_with_index do |project, index|
      progress = (100.0 * (index + 1) / board.projects.count).to_i
      @notifier.notify_progress("updating reports (#{progress}%)", progress)
      begin
        JiraTeamMetrics::ProjectReportBuilder.new(project).build
      rescue StandardError => e
        logger.error [
          "Error building reports for #{project.key}:",
          e.message,
          e.backtrace
        ].join("\n")
      end
    end
  end

  def sync_issues(board, credentials, months)
    @notifier.notify_status('fetching issues from JIRA')
    issues = fetch_issues_for_query(board, board.sync_query(months), credentials, 'fetching issues from JIRA')

    @notifier.notify_status('updating cache')
    issues.each do |i|
      board.issues.create(i)
    end

    @notifier.notify_status('following issue links')
    JiraTeamMetrics::IssueLinkerService.new(board).build_graph

    epic_keys = board.issues
      .select { |issue| !issue.fields['Epic Link'].nil? && issue.epic.nil? }
      .map { |issue| issue.fields['Epic Link'] }

    if epic_keys.length > 0
      epics = fetch_issues_for_query(board, "key in (#{epic_keys.join(',')})", credentials, 'fetching epics from JIRA')
      epics.each do |i|
        board.issues.create(i)
      end
    end

    board.synced_from = board.sync_from(months)
    board.last_synced = DateTime.now
    board.save
  end

  def delete_board(board)
    # TODO: this should be done in destroy callbacks
    @notifier.notify_status('clearing cache')

    board.issues.update_all(epic_id: nil, project_id: nil, parent_id: nil)

    board.issues.destroy_all
    board.filters.destroy_all
    board.report_fragments.destroy_all
    board.delete
  end

  def fetch_issues_for_query(board, query, credentials, status)
    client = JiraTeamMetrics::JiraClient.new(board.domain.config.url, credentials)
    JiraTeamMetrics::HttpErrorHandler.new(@notifier).invoke do
      client.search_issues(board.domain, query: query) do |progress|
        @notifier.notify_progress(status + ' (' + progress.to_s + '%)', progress)
      end
    end
  end

  def create_filters(board, credentials)
    board.config.filters.each do |filter|
      case filter
        when JiraTeamMetrics::BoardConfig::JqlFilter
          issues = fetch_issues_for_query(board, filter.query, credentials, 'syncing ' + filter.name + ' filter')
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :jql_filter)
        when JiraTeamMetrics::BoardConfig::MqlFilter
          issues = JiraTeamMetrics::LegacyMqlInterpreter.new(board, board.issues).eval(filter.query)
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :mql_filter)
        when JiraTeamMetrics::BoardConfig::ConfigFilter
          issue_keys = filter.issues.map{ |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :config_filter)
        else
          raise "Unexpected filter type: #{filter}"
      end
    end
  end

private
  def copy_board(prototype)
    attrs = prototype.slice('jira_id', 'name', 'query', 'config_string')
    prototype.domain.boards.create(attrs.merge('active': false))
  end

  def activate(board)
    board.domain.boards
      .where(jira_id: board.jira_id)
      .update_all(active: false)

    board.active = true
    board.save

    board.domain.boards
      .where(jira_id: board.jira_id, active: false)
      .each { |b| delete_board(b) }
  end

  def end_sync(domain)
    domain.with_lock do
      domain.syncing = false
      domain.save
    end
  end

  def find_target_board(jira_id, domain)
    board = domain.boards.find_by(jira_id: jira_id, active: true)
    if board.nil?
      # no active board, meaning we're syncing a new domain
      domain.boards.find_by(jira_id: jira_id)
    else
      # we have an active board, so copy it to sync
      copy_board(board)
    end
  end
end
