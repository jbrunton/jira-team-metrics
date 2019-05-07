class JiraTeamMetrics::SyncHistory < ApplicationRecord
  has_many :report_fragments

  def self.log(target, sync_history_id = nil)
    started_time = DateTime.now
    sync_history = JiraTeamMetrics::SyncHistory.create

    yield(sync_history.id)

    completed_time = DateTime.now
    jira_board_id = target.class == JiraTeamMetrics::Domain ? nil : target.jira_id

    sync_history.update_attributes(
      jira_board_id: jira_board_id,
      issues_count: target.issues.count,
      started_time: started_time,
      completed_time: completed_time,
      sync_history_id: sync_history_id
    )
  end
end
