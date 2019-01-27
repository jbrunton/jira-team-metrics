class JiraTeamMetrics::SyncBoardJob < ApplicationJob
  queue_as :default

  def perform(jira_id, domain, credentials, months, sync_history_id = nil)
    begin
      board = find_target_board(jira_id, domain)
      JiraTeamMetrics::SyncHistory.log(board, sync_history_id) do
        @notifier = JiraTeamMetrics::StatusNotifier.new(board, "syncing #{board.name}")

        sync_issues(board, credentials, months)
        create_filters(board, credentials)
        build_reports(board)
        activate(board)
      end
      @notifier.notify_complete
    ensure
      end_sync(domain) if domain.active?
    end
  end

  def build_reports(board)
    board.projects.each_with_index do |project, index|
      progress = (100.0 * (index + 1) / board.projects.count).to_i
      @notifier.notify_progress("updating reports (#{progress}%)", progress)
      begin
        JiraTeamMetrics::ProjectReportBuilder.new(project).build
      rescue StandardError => e
        logger.error [
          "Error building reports for #{project.key}:",
          e.message,
          e.backtrace
        ].join("\n")
      end
    end
  end

  def sync_issues(board, credentials, months)
    issue_sync_service = JiraTeamMetrics::IssueSyncService.new(board, credentials, @notifier)
    issue_linker_service = JiraTeamMetrics::IssueLinkerService.new(board, @notifier)

    issue_sync_service.sync_issues(months)
    issue_linker_service.build_graph
    issue_sync_service.sync_epics
    issue_linker_service.build_graph if board.config.link_missing_epics?(board.domain)

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
    board.report_fragments.destroy_all
    board.delete
  end



  def create_filters(board, credentials)
    board.config.filters.each do |filter|
      case filter
        when JiraTeamMetrics::BoardConfig::JqlFilter
          issues = fetch_issues_for_query(board, filter.query, credentials, 'syncing ' + filter.name + ' filter')
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :jql_filter)
        when JiraTeamMetrics::BoardConfig::MqlFilter
          issues = JiraTeamMetrics::MqlInterpreter.new.eval(filter.query, board, board.issues).rows
          issue_keys = issues.map { |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :mql_filter)
        when JiraTeamMetrics::BoardConfig::ConfigFilter
          issue_keys = filter.issues.map{ |issue| issue['key'] }.join(' ')
          board.filters.create(name: filter.name, issue_keys: issue_keys, filter_type: :config_filter)
        else
          raise "Unexpected filter type: #{filter}"
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
