class JiraTeamMetrics::RefreshReportJob < ApplicationJob
  queue_as :default

  def perform(jira_id, project_key, domain)
    Rails.logger.info "Preparing refresh for report with jira_id=#{jira_id}, project_key=#{project_key}."
    board = find_target_board(jira_id, domain)
    Rails.logger.info "Found board #{board}."
    JiraTeamMetrics::SyncHistory.log(board) do |sync_history_id|
      Rails.logger.info "Starting refresh for #{project_key}."
      @notifier = JiraTeamMetrics::StatusNotifier.new(board, "refreshing #{project_key}")

      build_report(board, project_key, sync_history_id)
      Rails.logger.info "Completed refresh for #{project_key}."
    end
    @notifier.notify_complete
  end

  def build_report(board, project_key, sync_history_id)
    if board.training_projects.any?
      Rails.logger.info "Training data available for #{board}, building reports."
    else
      Rails.logger.info "No training data available for #{board}, skipping reports."
      return
    end

    project = board.issues.find_by(key: project_key)

    @notifier.notify_status("updating report")
    begin
      Rails.logger.info "Building report for #{project.key}, for #{board}"
      JiraTeamMetrics::ProjectReportBuilder.new(project, sync_history_id).build
    rescue StandardError => e
      logger.error [
        "Error building reports for #{project.key}, for #{board}:",
        e.message,
        e.backtrace
      ].join("\n")
    end
  end

  def find_target_board(jira_id, domain)
    domain.boards.find_by(jira_id: jira_id, active: true)
  end
end
