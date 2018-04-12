class CreateReportFragments < ActiveRecord::Migration[5.1]
  def change
    create_table :report_fragments do |t|
      t.references :board, foreign_key: true
      t.string :report_key
      t.string :fragment_key
      t.text :contents

      t.timestamps
    end
  end
end
