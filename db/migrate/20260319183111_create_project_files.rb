class CreateProjectFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :project_files do |t|
      t.references :project, null: false, foreign_key: true
      t.string :file_type
      t.text :description

      t.timestamps
    end
  end
end
