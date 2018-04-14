class CreateDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_team_metrics_domains do |t|
      t.string :statuses
      t.string :fields
      t.text :config_string
      t.datetime :last_synced

      t.timestamps
    end
  end
end
