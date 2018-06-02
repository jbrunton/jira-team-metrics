class JiraTeamMetrics::SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(domain, credentials)
    domain.transaction do
      domain.syncing = true
      domain.save!
    end
    @notifier = JiraTeamMetrics::StatusNotifier.new(domain, "syncing #{domain.config.name}")
    clear_cache(domain)
    boards, statuses, fields = fetch_data(domain, credentials)
    update_cache(domain, boards, statuses, fields)

    domain.config.boards.each do |board_details|
      board = domain.boards.find_or_create_by(jira_id: board_details.board_id)
      board.config_string = board_details.fetch_config_string
      board.save
      JiraTeamMetrics::SyncBoardJob.perform_now(board, credentials, board.config.sync_months, false)
    end

    domain.transaction do
      domain.syncing = false
      domain.save!
    end
    @notifier.notify_complete
  end

private
  def clear_cache(domain)
    @notifier.notify_status('clearing cache')
    domain.boards.destroy_all
  end

  def fetch_data(domain, credentials)
    client = JiraTeamMetrics::JiraClient.new(domain.config.url, credentials)
    JiraTeamMetrics::HttpErrorHandler.new(@notifier).invoke do
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
