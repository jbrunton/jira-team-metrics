class JiraTeamMetrics::SyncBoardJob < ApplicationJob
  queue_as :default

  def perform(board, credentials, months, notify_complete = true)
    board.domain.transaction do
      board.syncing = true
      board.save!
    end
    begin
      @notifier = JiraTeamMetrics::StatusNotifier.new(board, "syncing #{board.name}")

      clear_cache(board)
      sync_issues(board, credentials, months)
      create_filters(board, credentials)
      build_reports(board)
    ensure
      board.transaction do
        board.syncing = false
        board.save!
      end
    end
    @notifier.notify_complete if notify_complete
  end

  def build_reports(board)
    board.increments.each_with_index do |increment, index|
      progress = (100.0 * (index + 1) / board.increments.count).to_i
      @notifier.notify_progress("updating reports (#{progress}%)", progress)
      begin
        JiraTeamMetrics::DeliveryReportBuilder.new(increment).build
      rescue StandardError => e
        logger.error [
          "Error building reports for #{increment.key}:",
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

  def clear_cache(board)
    @notifier.notify_status('clearing cache')

    board.issues.destroy_all
    board.filters.destroy_all
    board.report_fragments.destroy_all
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
        when JiraTeamMetrics::BoardConfig::QueryFilter
          issues = fetch_issues_for_query(board, filter.query, credentials, 'syncing ' + filter.name + ' filter')
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :query_filter)
        when JiraTeamMetrics::BoardConfig::ConfigFilter
          issue_keys = filter.issues.map{ |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :config_filter)
        else
          raise "Unexpected filter type: #{filter}"
      end
    end
  end
end
