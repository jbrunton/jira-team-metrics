class AddIconsToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :jira_team_metrics_issues, :issue_type_icon, :string
  end
end
