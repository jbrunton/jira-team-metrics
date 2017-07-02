class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain, username, password)
    #TODO: do this in a transaction
    clear_cache(domain)
    boards, statuses = fetch_data(domain, {username: username, password: password})
    update_cache(domain, boards, statuses)
    notify_complete(domain)
  end

private
  def clear_cache(domain)
    notify_status(domain, 'clearing cache')
    domain.boards.destroy_all
  end

  def fetch_data(domain, credentials)
    notify_status(domain, 'fetching from JIRA')
    client = JiraClient.new(domain.url, credentials)
    begin
      boards = client.get_rapid_boards
      statuses = client.get_statuses
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      notify_error(domain, e.message, e.try(:response).try(:code))
      raise
    end

    [boards, statuses]
  end

  def update_cache(domain, boards, statuses)
    notify_status(domain, 'updating cache')

    boards.each do |b|
      domain.boards.create(b)
    end

    domain.last_synced = DateTime.now
    domain.statuses = statuses
    domain.save
  end

  def notify_status(domain, status)
    SyncDomainChannel.broadcast_to(
      domain,
      status: status,
      in_progress: true
    )
  end

  def notify_complete(domain)
    SyncDomainChannel.broadcast_to(
      domain,
      in_progress: false
    )
  end

  def notify_error(domain, error, error_code)
    SyncDomainChannel.broadcast_to(
      domain,
      error: error,
      errorCode: error_code,
      in_progress: false
    )
  end
end
