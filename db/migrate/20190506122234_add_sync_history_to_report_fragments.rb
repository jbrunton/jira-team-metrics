class AddSyncHistoryToReportFragments < ActiveRecord::Migration[5.2]
  def change
    add_reference :jira_team_metrics_report_fragments, :sync_history, foreign_key: {to_table: :jira_team_metrics_sync_histories}
  end
end
