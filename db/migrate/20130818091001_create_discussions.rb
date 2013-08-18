class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.integer :annotation_id
      t.integer :member_id
      t.string :text

      t.timestamps
    end

    add_index :discussions, :annotation_id
    add_index :discussions, :member_id
  end
end
