class CreateJiraTeamMetricsSyncHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :jira_team_metrics_sync_histories do |t|
      t.references :domain, foreign_key: false, index: true
      t.references :board, foreign_key: false, index: true
      t.integer :issues_count
      t.datetime :started_time
      t.datetime :completed_time

      t.timestamps
    end
  end
end
