class AddSyncFieldToDomains < ActiveRecord::Migration[5.2]
  def change
    add_column :jira_team_metrics_domains, :syncing, :boolean
    add_column :jira_team_metrics_boards, :syncing, :boolean
  end
end
