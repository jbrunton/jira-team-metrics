class JiraTeamMetrics::SyncDomainJob < ApplicationJob
  queue_as :default

  def perform(credentials)
    active_domain = JiraTeamMetrics::Domain.get_active_instance
    domain = copy_domain(active_domain)

    @notifier = JiraTeamMetrics::StatusNotifier.new(active_domain, "syncing #{domain.config.name}")
    boards, statuses, fields = fetch_data(domain, credentials)
    update_cache(domain, boards, statuses, fields)

    domain.config.boards.each do |board_details|
      board = domain.boards.find_or_create_by(jira_id: board_details.board_id)
      board.config_string = board_details.fetch_config_string(ENV['CONFIG_DIR'])
      board.save
      JiraTeamMetrics::SyncBoardJob.perform_now(board.jira_id, domain, credentials, board.config.sync_months)
    end
    activate(domain)
    @notifier.notify_complete
  end

private
  def delete_domain(domain)
    @notifier.notify_status('clearing cache')
    domain.boards.destroy_all
    domain.destroy
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

  def copy_domain(prototype)
    attrs = prototype.slice('config_string')
    JiraTeamMetrics::Domain.create(attrs.merge('active': false))
  end

  def activate(domain)
    JiraTeamMetrics::Domain
      .update_all(active: false)

    domain.active = true
    domain.save

    JiraTeamMetrics::Domain
      .where(active: false)
      .each { |d| delete_domain(d) }

    domain.boards
      .update_all(active: true)

    JiraTeamMetrics::Domain.clear_cache
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
