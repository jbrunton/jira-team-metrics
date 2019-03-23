class AddTagsToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :jira_team_metrics_issues, :tags, :string
    add_column :jira_team_metrics_issues, :json, :text
  end
end
