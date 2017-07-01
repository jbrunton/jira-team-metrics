class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain, username, password)
    puts "*** Syncing #{domain.name}"
    ActionCable.server.broadcast(
      "sync_status",
      domain: domain.id,
      status: 'syncing'
    )

    #TODO: do this in a transaction
    domain.boards.destroy_all
    boards = JiraClient.new(domain.url, {username: username, password: password}).get_rapid_boards
    boards.each do |b|
      domain.boards.create(b)
    end

    domain.last_synced = DateTime.now
    domain.save

    ActionCable.server.broadcast(
      "sync_status",
      domain: domain.id,
      status: 'done'
    )
    # Do something later
  end
end
