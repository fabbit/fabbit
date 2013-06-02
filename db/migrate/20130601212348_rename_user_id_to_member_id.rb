class RenameUserIdToMemberId < ActiveRecord::Migration
  def up
    rename_column :annotations, :user_id, :member_id
  end

  def down
    rename_column :annotations, :member_id, :user_id
  end
end
