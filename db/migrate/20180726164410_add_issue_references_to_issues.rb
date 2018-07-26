class AddIssueReferencesToIssues < ActiveRecord::Migration[5.2]
  def change
    add_reference :jira_team_metrics_issues, :epic, foreign_key: {to_table: :jira_team_metrics_issues}
    add_reference :jira_team_metrics_issues, :project, foreign_key: {to_table: :jira_team_metrics_issues}
    add_reference :jira_team_metrics_issues, :parent, foreign_key: {to_table: :jira_team_metrics_issues}

    add_column :jira_team_metrics_issues, :epic_key, :string
    add_column :jira_team_metrics_issues, :project_key, :string
    add_column :jira_team_metrics_issues, :parent_key, :string
  end
end
