class CreateJiraTeamMetricsSyncHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :jira_team_metrics_sync_histories do |t|
      t.string :jira_board_id
      t.integer :issues_count
      t.datetime :started_time
      t.datetime :completed_time
      t.references :sync_history, index: true, foreign_key: false

      t.timestamps
    end
  end
end
