class CreateFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :filters do |t|
      t.string :name
      t.string :issue_keys
      t.references :board, foreign_key: true

      t.timestamps
    end
  end
end
