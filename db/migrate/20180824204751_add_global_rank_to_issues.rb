class AddGlobalRankToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :jira_team_metrics_issues, :global_rank, :string
    add_column :jira_team_metrics_issues, :resolution, :string
  end
end
