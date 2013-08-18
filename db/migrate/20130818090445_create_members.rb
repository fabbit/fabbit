class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.integer :dropbox_uid
      t.string :name

      t.timestamps
    end

    add_index :members, :dropbox_uid
  end
end
