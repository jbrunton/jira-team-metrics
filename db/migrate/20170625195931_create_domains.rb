class CreateDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :domains do |t|
      t.string :name
      t.string :url
      t.string :statuses
      t.string :fields
      t.text :config_string
      t.datetime :last_synced

      t.timestamps
    end
  end
end
