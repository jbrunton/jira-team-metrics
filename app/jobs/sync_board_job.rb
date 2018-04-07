class SyncBoardJob < ApplicationJob
  queue_as :default

  def perform(board, username, password, notify_complete = true)
    #TODO: do this in a transaction

    @notifier = StatusNotifier.new(board, "syncing #{board.name}")

    @notifier.notify_status('clearing cache')

    board.issues.destroy_all
    board.filters.destroy_all

    @notifier.notify_status('fetching issues from JIRA')

    credentials = {username: username, password: password}
    issues = fetch_issues_for(board, credentials)

    @notifier.notify_status('updating cache')

    issues.each do |i|
      board.issues.create(i)
    end
    board.last_synced = DateTime.now
    board.save

    epic_keys = board.issues
      .select { |issue| !issue.fields['Epic Link'].nil? && issue.epic.nil? }
      .map{ |issue| issue.fields['Epic Link'] }

    if epic_keys.length > 0
      epics = fetch_issues_for_query(board, "key in (#{epic_keys.join(',')})", credentials, 'fetching epics from JIRA', true)
      epics.each do |i|
        board.issues.create(i)
      end
    end

    create_filters(board, credentials)

    @notifier.notify_complete if notify_complete
  end

  def fetch_issues_for(board, credentials)
    fetch_issues_for_query(board, nil, credentials, 'fetching issues from JIRA')
  end

  def fetch_issues_for_query(board, subquery, credentials, status, ignore_board_query = false)
    if ignore_board_query
      query = subquery
    elsif subquery
      query = QueryBuilder.new(board.query)
        .and(subquery)
        .query
    else
      query = board.query
    end
    client = JiraClient.new(board.domain.config.url, credentials)
    HttpErrorHandler.new(@notifier).invoke do
      client.search_issues(board.domain, query: query) do |progress|
        @notifier.notify_progress(status + ' (' + progress.to_s + '%)', progress)
      end
    end
  end

  def create_filters(board, credentials)
    board.config.filters.each do |filter|
      case filter
        when BoardConfig::QueryFilter
          issues = fetch_issues_for_query(board, filter.query, credentials, 'syncing ' + filter.name + ' filter')
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :query_filter)
        when BoardConfig::ConfigFilter
          issue_keys = filter.issues.map{ |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :config_filter)
        else
          raise "Unexpected filter type: #{filter}"
      end
    end
  end
end
