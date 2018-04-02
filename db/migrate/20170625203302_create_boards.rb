class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.string :jira_id
      t.string :name
      t.string :query
      t.text :config_string
      t.datetime :synced_from
      t.datetime :last_synced
      t.references :domain, foreign_key: true

      t.timestamps
    end
  end
end
