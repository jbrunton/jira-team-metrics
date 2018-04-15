class CreateReportFragments < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_team_metrics_report_fragments do |t|
      # TODO: add foreign key for this column
      t.references :board, index: true, foreign_key: false
      t.string :report_key
      t.string :fragment_key
      t.text :contents

      t.timestamps
    end
  end
end
