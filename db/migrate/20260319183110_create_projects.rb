class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :customer
      t.string :address
      t.text :description

      t.timestamps
    end
  end
end
