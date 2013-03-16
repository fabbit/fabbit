class CreateRevisions < ActiveRecord::Migration
  def change
    create_table :revisions do |t|
      t.integer :model_file_id
      t.integer :revision_number

      t.timestamps
    end
    add_index :revisions, [:model_file_id, :revision_number ]
  end
end
