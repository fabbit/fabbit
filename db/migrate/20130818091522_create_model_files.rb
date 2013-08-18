class CreateModelFiles < ActiveRecord::Migration
  def change
    create_table :model_files do |t|
      t.integer :member_id
      t.string :path

      t.timestamps
    end

    add_index :model_files, [:member_id, :path], unique: true
  end
end
