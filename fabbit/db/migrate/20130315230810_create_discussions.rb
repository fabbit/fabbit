class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.integer :annotation_id
      t.string :uid
      t.string :text

      t.timestamps
    end
  end
end
