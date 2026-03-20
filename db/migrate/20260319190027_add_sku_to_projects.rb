class AddSkuToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :sku, :string
    add_index :projects, :sku
  end
end
