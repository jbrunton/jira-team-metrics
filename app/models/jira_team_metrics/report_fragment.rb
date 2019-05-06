class JiraTeamMetrics::ReportFragment < ApplicationRecord
  serialize :contents
  belongs_to :sync_history

  # TODO: join with board_id
  def self.fetch(jira_id, report_key, fragment_key, sync_history_id = nil)
    if sync_history_id.nil?
      JiraTeamMetrics::ReportFragment
        .joins(:sync_history)
        .where(report_key: report_key, fragment_key: fragment_key)
        .where(jira_team_metrics_sync_histories: { jira_board_id: jira_id })
        .order(created_at: :desc)
        .first
    else
      JiraTeamMetrics::ReportFragment
        .find_by(report_key: report_key, fragment_key: fragment_key, sync_history_id: sync_history_id)
    end
  end

  def self.fetch_contents(jira_id, report_key, fragment_key, sync_history_id = nil)
    fragment = fetch(jira_id, report_key, fragment_key, sync_history_id)
    fragment.contents unless fragment.nil?
  end
end
