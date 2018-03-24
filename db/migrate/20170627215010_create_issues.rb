class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.string :key
      t.string :issue_type
      t.string :summary
      t.datetime :issue_created
      t.string :labels
      t.string :transitions
      t.string :fields
      t.string :links
      t.references :board, foreign_key: true

      t.timestamps
    end
  end
end
