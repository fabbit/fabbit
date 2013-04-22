class CreateProjectMembers < ActiveRecord::Migration
  def change
    create_table :project_members do |t|
      t.integer :project_id
      t.integer :member_id

      t.timestamps
    end

    add_index :project_members, :project_id
    add_index :project_members, :member_id
  end
end
