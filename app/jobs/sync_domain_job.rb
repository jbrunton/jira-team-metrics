class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain, username, password)
    #TODO: do this in a transaction
    SyncDomainChannel.broadcast_to(
      domain,
      status: 'clearing cache',
      in_progress: true
    )

    domain.boards.destroy_all

    SyncDomainChannel.broadcast_to(
      domain,
      status: 'fetching from JIRA',
      in_progress: true
    )

    boards = JiraClient.new(domain.url, {username: username, password: password}).get_rapid_boards

    SyncDomainChannel.broadcast_to(
      domain,
      status: 'updating cache',
      in_progress: true
    )

    boards.each do |b|
      domain.boards.create(b)
    end

    domain.last_synced = DateTime.now
    domain.save

    SyncDomainChannel.broadcast_to(
      domain,
      in_progress: false
    )
    # Do something later
  end
end
