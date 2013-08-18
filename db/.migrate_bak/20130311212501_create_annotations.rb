class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :revision_id
      t.string :coordinates
      t.string :camera
      t.string :text

      t.timestamps
    end
    add_index :annotations, :revision_id
  end
end
