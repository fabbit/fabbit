class CreateProjectModelFiles < ActiveRecord::Migration
  def change
    create_table :project_model_files do |t|
      t.integer :project_id
      t.integer :model_file_id

      t.timestamps
    end

    add_index :project_model_files, :project_id
    add_index :project_model_files, :model_file_id
  end
end
