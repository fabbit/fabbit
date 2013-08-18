class CreateGroupProjects < ActiveRecord::Migration
  def change
    create_table :group_projects do |t|
      t.integer :group_id
      t.integer :project_id

      t.timestamps
    end

    add_index :group_projects, :group_id
    add_index :group_projects, :project_id

  end
end
