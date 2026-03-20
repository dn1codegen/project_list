class AddRememberTokenToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :remember_token, :string
  end
end
