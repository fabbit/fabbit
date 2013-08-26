class AddAttachmentToVersions < ActiveRecord::Migration
  def up
    add_attachment :versions, :file
  end

  def down
    remove_attachment :versions, :file
  end
end
