class AddRevisionDateToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :revision_date, :datetime
    add_index :versions, :revision_date
  end
end
