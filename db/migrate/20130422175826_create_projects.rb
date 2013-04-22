class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :project_type_id

      t.timestamps
    end

    add_index :projects, :project_type_id
  end
end
