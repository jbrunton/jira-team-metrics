class RemoveBoardFromReportFragments < ActiveRecord::Migration[5.2]
  def change
    remove_column :jira_team_metrics_report_fragments, :board_id
  end
end
