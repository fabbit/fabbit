class AddDetailsToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :details, :string
  end
end
