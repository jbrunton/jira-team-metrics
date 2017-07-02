class SyncBoardJob < ApplicationJob
  queue_as :default

  def perform(board, username, password)
    #TODO: do this in a transaction
    SyncBoardChannel.broadcast_to(
      board,
      status: 'clearing cache',
      in_progress: true
    )

    board.issues.destroy_all
    board.filters.destroy_all

    SyncBoardChannel.broadcast_to(
      board,
      status: 'fetching from JIRA',
      in_progress: true
    )
    
    credentials = {username: username, password: password}
    sync_from = Time.now - (180 * 60 * 60 * 24)
    issues = fetch_issues_for(board, sync_from, credentials)

    SyncBoardChannel.broadcast_to(
      board,
      status: 'updating cache',
      in_progress: true
    )

    issues.each do |i|
      board.issues.create(i)
    end
    board.last_synced = DateTime.now
    board.synced_from = sync_from
    board.save

    create_filters(board, credentials)

    SyncBoardChannel.broadcast_to(
      board,
      in_progress: false
    )
    # Do something later
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
    client = JiraClient.new(board.domain.url, credentials)
    issues = client.search_issues(query: query, statuses: statuses) do |progress|
      SyncBoardChannel.broadcast_to(
        board,
        status: status + ' (' + progress.to_s + '%)',
        in_progress: true,
        progress: progress
      )
    end
    issues
  end

  def create_filters(board, credentials)
    board.config_filters.each do |filter|
      issues = fetch_issues_for_query(board, filter['query'], credentials, 'syncing ' + filter['name'] + ' filter')
      issue_keys = issues.map { |issue| issue['key'] }.join(' ')
      board.filters.create(name: filter['name'], issue_keys: issue_keys, filter_type: :query_filter)
    end

    board.filters.create(name: 'Excluded Issues', filter_type: :config_filter)
  end
end
