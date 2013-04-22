class RenameUserToMember < ActiveRecord::Migration
  def up
    rename_table :users, :members
    rename_column :discussions, :user_id, :member_id
    rename_column :model_files, :user_id, :member_id
  end

  def down
    rename_table :members, :users
    rename_column :discussions, :member_id, :user_id
    rename_column :model_files, :member_id, :user_id
  end
end
