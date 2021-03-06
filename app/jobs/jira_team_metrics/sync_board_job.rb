class JiraTeamMetrics::SyncBoardJob < ApplicationJob
  queue_as :default

  def perform(jira_id, domain, credentials, months, sync_history_id = nil)
    begin
      Rails.logger.info "Preparing sync for board jira_id=#{jira_id}."
      board = find_target_board(jira_id, domain)
      Rails.logger.info "Found board #{board}."
      JiraTeamMetrics::SyncHistory.log(board, sync_history_id) do |sync_history_id|
        Rails.logger.info "Starting sync for #{board}."
        @notifier = JiraTeamMetrics::StatusNotifier.new(board, "syncing #{board.name}")

        update_config(domain, board)
        sync_issues(board, credentials, months)
        create_filters(board, credentials)
        build_reports(board, sync_history_id)
        activate(board)
        Rails.logger.info "Completed sync for #{board}."
      end
      @notifier.notify_complete
    ensure
      end_sync(domain) if domain.active?
    end
  end

  def update_config(domain, board)
    Rails.logger.info "Checking for config for #{board}."
    board_details = domain.config.boards.find{ |it| it.board_id.to_s == board.jira_id }
    if board_details.nil?
      Rails.logger.info "No config found for #{board}."
    else
      Rails.logger.info "Config found for #{board}."
      JiraTeamMetrics::ConfigFileService.load_board_config(board, board_details.config_file)
      board.save
    end
  end

  def build_reports(board, sync_history_id)
    if board.training_projects.any?
      Rails.logger.info "Training data available for #{board}, building reports."
    else
      Rails.logger.info "No training data available for #{board}, skipping reports."
      return
    end

    board.projects.each_with_index do |project, index|
      progress = (100.0 * (index + 1) / board.projects.count).to_i
      @notifier.notify_progress("updating reports (#{progress}%)", progress)
      begin
        Rails.logger.info "Building reports for #{project.key}, for #{board}"
        JiraTeamMetrics::ProjectReportBuilder.new(project, sync_history_id).build
      rescue StandardError => e
        logger.error [
          "Error building reports for #{project.key}, for #{board}:",
          e.message,
          e.backtrace
        ].join("\n")
      end
    end
  end

  def sync_issues(board, credentials, months)
    Rails.logger.info "Syncing issues for #{board}."
    issue_sync_service = JiraTeamMetrics::IssueSyncService.new(board, credentials, @notifier)
    issue_linker_service = JiraTeamMetrics::IssueLinkerService.new(board, @notifier)

    issue_sync_service.sync_issues(months)
    issue_linker_service.build_graph
    issue_sync_service.sync_epics
    issue_sync_service.sync_projects
    issue_linker_service.build_graph if board.config.epics.link_missing

    board.synced_from = board.sync_from(months)
    board.last_synced = DateTime.now
    board.save
  end

  def delete_board(board)
    # TODO: this should be done in destroy callbacks
    @notifier.notify_status('clearing cache')

    board.issues.update_all(epic_id: nil, project_id: nil, parent_id: nil)

    board.issues.destroy_all
    board.filters.destroy_all
    #board.report_fragments.destroy_all
    board.delete
  end



  def create_filters(board, credentials)
    board.config.filters.each do |filter|
      case filter.type
        when 'jql'
          issues = fetch_issues_for_query(board, filter.query, credentials, 'syncing ' + filter.name + ' filter')
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :jql_filter)
        when 'mql'
          issues = JiraTeamMetrics::MqlInterpreter.new.eval(filter.query, board, board.issues).rows
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :mql_filter)
        else
          raise "Unexpected filter type: #{filter.type}"
      end
    end
  end

private
  def copy_board(prototype)
    attrs = prototype.slice('jira_id', 'name', 'query', 'config_string')
    prototype.domain.boards.create(attrs.merge(active: false))
  end

  def activate(board)
    board.domain.boards
      .where(jira_id: board.jira_id)
      .update_all(active: false)

    board.active = true
    board.save

    board.domain.boards
      .where(jira_id: board.jira_id, active: false)
      .each { |b| delete_board(b) }
  end

  def end_sync(domain)
    domain.with_lock do
      domain.syncing = false
      domain.save
    end
  end

  def find_target_board(jira_id, domain)
    board = domain.boards.find_by(jira_id: jira_id, active: true)
    if board.nil?
      # no active board, meaning we're syncing a new domain
      domain.boards.find_by(jira_id: jira_id)
    else
      # we have an active board, so copy it to sync
      copy_board(board)
    end
  end
end
