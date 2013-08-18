class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :dropbox_uid

      t.timestamps
    end

    add_index :users, :dropbox_uid
  end
end
