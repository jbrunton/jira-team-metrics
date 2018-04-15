class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_team_metrics_issues do |t|
      t.string :key
      t.string :issue_type
      t.string :summary
      t.datetime :issue_created
      t.string :status
      t.string :labels
      t.string :transitions
      t.string :fields
      t.string :links
      # TODO: add foreign key for this column
      t.references :board, index: true, foreign_key: false

      t.timestamps
    end
  end
end
