class RenameUidToUserId < ActiveRecord::Migration
  def up
    rename_column :discussions, :uid, :user_id
  end

  def down
    rename_column :discussions, :user_id, :uid
  end
end
