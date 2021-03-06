class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_team_metrics_boards do |t|
      t.string :jira_id
      t.string :name
      t.string :query
      t.text :config_string
      t.datetime :synced_from
      t.datetime :last_synced
      # TODO: add foreign key for this column
      t.references :domain, index: true, foreign_key: false

      t.timestamps
    end
  end
end
