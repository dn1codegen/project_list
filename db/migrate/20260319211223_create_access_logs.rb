class CreateAccessLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :access_logs do |t|
      t.references :web_access_key, null: false, foreign_key: true
      t.string :ip_address
      t.text :user_agent
      t.datetime :entered_at
      t.datetime :exited_at
      t.integer :duration

      t.timestamps
    end
  end
end
