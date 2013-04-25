class RenameRevisionToVersion < ActiveRecord::Migration
  def change
    rename_table :revisions, :versions
    rename_column :annotations, :revision_id, :version_id
  end
end
