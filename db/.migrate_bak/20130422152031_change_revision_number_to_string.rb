class ChangeRevisionNumberToString < ActiveRecord::Migration
  def up
    change_column :revisions, :revision_number, :string
    change_column :model_files, :cached_revision, :string
  end

  def down
    remove_column :revisions, :revision_number
    add_column :revisions, :revision_number, :integer
    remove_column :model_files, :cached_revision
    add_column :model_files, :cached_revision, :integer
  end
end
