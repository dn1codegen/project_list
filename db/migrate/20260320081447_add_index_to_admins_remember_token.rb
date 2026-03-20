class AddIndexToAdminsRememberToken < ActiveRecord::Migration[8.1]
  def change
    add_index :admins, :remember_token, unique: true
  end
end
