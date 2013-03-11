class CreateModelFiles < ActiveRecord::Migration
  def change
    create_table :model_files do |t|
      t.string :user
      t.string :path
      t.integer :cached_revision

      t.timestamps
    end
    add_index :model_files, :user
    add_index :model_files, [:path, :cached_revision]
  end
end
