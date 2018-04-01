class SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain, username, password)
    #TODO: do this in a transaction
    @notifier = StatusNotifier.new(domain, "syncing #{domain.name}")
    clear_cache(domain)
    boards, statuses, fields = fetch_data(domain, {username: username, password: password})
    update_cache(domain, boards, statuses, fields)

    (domain.config_hash['boards'] || []).each do |board_details|
      board = domain.boards.find_by(jira_id: board_details['jira_id'])
      board.config = board_details['config'].to_yaml(line_width: -1)
      board.save
      SyncBoardJob.perform_now(board, username, password, 180, false)
    end

    @notifier.notify_complete
  end

private
  def clear_cache(domain)
    @notifier.notify_status('clearing cache')
    domain.boards.destroy_all
  end

  def fetch_data(domain, credentials)
    client = JiraClient.new(domain.url, credentials)
    HttpErrorHandler.new(@notifier).invoke do
      @notifier.notify_status('fetching boards from JIRA')
      boards = client.get_rapid_boards

      @notifier.notify_status('fetching status metadata from JIRA')
      statuses = client.get_statuses

      @notifier.notify_status('fetching fields from JIRA')
      fields = client.get_fields.select do |field|
        (['Epic Link'] + domain.config.fields).include?(field['name'])
      end

      [boards, statuses, fields]
    end
  end

  def update_cache(domain, boards, statuses, fields)
    @notifier.notify_status('updating cache')

    boards.each do |b|
      domain.boards.create(b)
    end

    domain.last_synced = DateTime.now
    domain.statuses = statuses
    domain.fields = fields
    domain.save
  end
end
