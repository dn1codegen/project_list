class AddKeyTypeToApiKeys < ActiveRecord::Migration[8.1]
  def change
    add_column :api_keys, :key_type, :string, default: 'web_access', null: false
  end
end
