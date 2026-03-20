class CreateApiKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :api_keys do |t|
      t.string :key
      t.string :name
      t.boolean :active

      t.timestamps
    end

    add_index :api_keys, :key, unique: true
  end
end
