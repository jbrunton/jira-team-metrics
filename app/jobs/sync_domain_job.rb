class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain)
    puts "*** Syncing #{domain.name}"
    ActionCable.server.broadcast(
      "sync_status",
      domain: domain.id,
      status: 'syncing'
    )
    sleep(5)
    puts "*** Done"

    ActionCable.server.broadcast(
      "sync_status",
      domain: domain.id,
      status: 'done'
    )
    # Do something later
  end
end
