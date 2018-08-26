class AddActiveFlags < ActiveRecord::Migration[5.2]
  def change
    add_column :jira_team_metrics_domains, :active, :boolean
    add_column :jira_team_metrics_boards, :active, :boolean

    reversible do |change|
      change.up do
        execute "UPDATE jira_team_metrics_domains SET active = 't'"
        execute "UPDATE jira_team_metrics_boards SET active = 't'"
      end
    end
  end
end
