class AddJiraProjectToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :jira_team_metrics_issues, :jira_project, :string
  end
end
