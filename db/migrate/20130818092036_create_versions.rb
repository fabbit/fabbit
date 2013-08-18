class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.integer :model_file_id
      t.string :revision_number
      t.string :details
      t.datetime :revision_date

      t.timestamps
    end

    add_index :versions, [:model_file_id, :revision_number], unique: true
    add_index :versions, :revision_date
  end
end
