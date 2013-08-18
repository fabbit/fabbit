class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :group_type_id

      t.timestamps
    end

    add_index :groups, :group_type_id
  end
end
