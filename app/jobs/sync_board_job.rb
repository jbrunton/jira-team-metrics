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
    sync_from = Time.now - (180 * 60 * 60 * 24)
    issues = fetch_issues_for(board, sync_from, credentials)

    @notifier.notify_status('updating cache')

    issues.each do |i|
      board.issues.create(i)
    end
    board.last_synced = DateTime.now
    board.synced_from = sync_from
    board.save

    create_filters(board, credentials)

    @notifier.notify_complete if notify_complete
  end

  def fetch_issues_for(board, since_date, credentials)
    query = "status changed AFTER '#{since_date.strftime('%Y-%m-%d')}'"
    fetch_issues_for_query(board, query, credentials, 'fetching issues from JIRA')
  end

  def fetch_issues_for_query(board, subquery, credentials, status)
    query = QueryBuilder.new(board.query)
      .and(subquery)
      .query
    statuses = board.domain.statuses
    fields = board.domain.fields
    client = JiraClient.new(board.domain.url, credentials)
    HttpErrorHandler.new(@notifier).invoke do
      client.search_issues(query: query, statuses: statuses, fields: fields) do |progress|
        @notifier.notify_progress(status + ' (' + progress.to_s + '%)', progress)
      end
    end
  end

  def create_filters(board, credentials)
    board.config_filters.each do |filter|
      if filter['query']
        issues = fetch_issues_for_query(board, filter['query'], credentials, 'syncing ' + filter['name'] + ' filter')
        issue_keys = issues.map { |issue| issue['key'] }.join(' ')
        board.filters.create(name: filter['name'], issue_keys: issue_keys, filter_type: :query_filter)
      else
        issue_keys = filter['issues'].map{ |issue| issue['key'] }.join(' ')
        board.filters.create(name: filter['name'], issue_keys: issue_keys, filter_type: :config_filter)
      end
    end
  end
end
