class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain)
    puts "*** Syncing #{domain.name}"
    sleep(5)
    puts "*** Done"

    ActionCable.server.broadcast(
      "sync_status",
      domain: domain.id
    )
    # Do something later
  end
end
