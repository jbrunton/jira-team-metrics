class CreateFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_team_metrics_filters do |t|
      t.string :name
      t.string :issue_keys
      t.integer :filter_type
      # TODO: add foreign key for this column
      t.references :board, index: true, foreign_key: false

      t.timestamps
    end
  end
end
