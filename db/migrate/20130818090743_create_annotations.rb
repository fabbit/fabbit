class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :version_id
      t.integer :member_id
      t.string :coordinates
      t.string :camera
      t.string :text

      t.timestamps
    end

    add_index :annotations, :version_id
    add_index :annotations, :member_id
  end
end
