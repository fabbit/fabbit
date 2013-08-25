class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :member_id
      t.integer :count, default: 0

      t.timestamps
    end

    add_index :notifications, :member_id
  end
end
