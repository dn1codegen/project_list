class CreateProjectKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :project_keys do |t|
      t.string :name
      t.string :key
      t.boolean :active

      t.timestamps
    end
  end
end
