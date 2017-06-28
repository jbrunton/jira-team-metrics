class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain)
    puts "*** Syncing #{domain.name}"
    sleep(5)
    puts "*** Done"
    # Do something later
  end
end
