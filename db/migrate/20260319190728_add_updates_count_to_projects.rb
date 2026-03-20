class AddUpdatesCountToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :updates_count, :integer, default: 0, null: false
  end
end
