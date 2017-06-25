class CreateDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :domains do |t|
      t.string :name
      t.string :url
      t.string :statuses
      t.datetime :last_synced

      t.timestamps
    end
  end
end
