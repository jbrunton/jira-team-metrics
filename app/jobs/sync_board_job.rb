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

    # client = JiraClient.new(board.domain.url, {username: username, password: password})
    # begin
    #   boards = client.get_rapid_boards
    # rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
    #   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    #   SyncBoardChannel.broadcast_to(
    #     board,
    #     error: e.message,
    #     errorCode: e.try(:response).try(:code),
    #     in_progress: false
    #   )
    #   raise
    # end

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

    board.config_filters.each do |filter|
      issues = fetch_issues_for_query(board, filter['query'], credentials)
      issue_keys = issues.map{ |issue| issue['key'] }.join(' ')
      board.filters.create(name: filter['name'], issue_keys: issue_keys)
    end

    SyncBoardChannel.broadcast_to(
      board,
      in_progress: false
    )
    # Do something later
  end

  def fetch_issues_for(board, since_date, credentials)
    query = "status changed AFTER '#{since_date.strftime('%Y-%m-%d')}'"
    fetch_issues_for_query(board, query, credentials)
  end

  def fetch_issues_for_query(board, subquery, credentials)
    query = QueryBuilder.new(board.query)
      .and(subquery)
      .query
    statuses = board.domain.statuses
    client = JiraClient.new(board.domain.url, credentials)
    issues = client.search_issues(query: query, statuses: statuses) do |progress|
      SyncBoardChannel.broadcast_to(
        board,
        status: 'fetching from JIRA (' + progress.to_s + '%)',
        in_progress: true,
        progress: progress
      )
    end
    issues
  end
end
