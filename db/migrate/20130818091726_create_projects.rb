class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :notify, default: false
      t.boolean :share, default: false

      t.timestamps
    end
  end
end
