class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain, username, password)
    #TODO: do this in a transaction
    @notifier = StatusNotifier.new(domain, "Syncing #{domain.name}: ")
    clear_cache(domain)
    boards, statuses = fetch_data(domain, {username: username, password: password})
    update_cache(domain, boards, statuses)
    @notifier.notify_complete

    domain.config_hash['boards'].each do |board_details|
      board = domain.boards.find_by(jira_id: board_details['jira_id'])
      board.config = board_details['config'].to_yaml(line_width: -1)
      board.save
      SyncBoardJob.perform_now(board, username, password)
    end
  end

private
  def clear_cache(domain)
    @notifier.notify_status('clearing cache')
    domain.boards.destroy_all
  end

  def fetch_data(domain, credentials)
    @notifier.notify_status('fetching from JIRA')
    client = JiraClient.new(domain.url, credentials)
    begin
      boards = client.get_rapid_boards
      statuses = client.get_statuses
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      @notifier.notify_error(e.message, e.try(:response).try(:code))
      raise
    end

    [boards, statuses]
  end

  def update_cache(domain, boards, statuses)
    @notifier.notify_status('updating cache')

    boards.each do |b|
      domain.boards.create(b)
    end

    domain.last_synced = DateTime.now
    domain.statuses = statuses
    domain.save
  end
end
