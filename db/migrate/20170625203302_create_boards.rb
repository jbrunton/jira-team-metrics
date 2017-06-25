class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.string :name
      t.string :query
      t.references :domain, foreign_key: true

      t.timestamps
    end
  end
end
