class CreateFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_team_metrics_filters do |t|
      t.string :name
      t.string :issue_keys
      t.integer :filter_type
      t.references :board, foreign_key: true

      t.timestamps
    end
  end
end
