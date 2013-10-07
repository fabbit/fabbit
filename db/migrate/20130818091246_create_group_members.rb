class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.integer :group_id
      t.integer :member_id
      t.boolean :admin

      t.timestamps
    end

    add_index :group_members, [:group_id, :member_id], unique: true
    add_index :group_members, :group_id
    add_index :group_members, :member_id
  end
end
