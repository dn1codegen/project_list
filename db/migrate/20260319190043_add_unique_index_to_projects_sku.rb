class AddUniqueIndexToProjectsSku < ActiveRecord::Migration[8.1]
  def change
    remove_index :projects, :sku
    add_index :projects, :sku, unique: true
  end
end
