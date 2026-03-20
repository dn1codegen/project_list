class CreateWebAccessKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :web_access_keys do |t|
      t.string :name
      t.string :key
      t.boolean :active

      t.timestamps
    end
  end
end
