class AddUserIdToModelFiles < ActiveRecord::Migration
  def change
    add_column :model_files, :user_id, :integer
  end
end
