# == Schema Information
#
# Table name: model_files
#
#  id              :integer          not null, primary key
#  user            :string(255)
#  path            :string(255)
#  cached_revision :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#

# == Description
#
# A ModelFile corresponds to a file that a Fabbit member has used. It is generated upon accessing
# the file through Fabbit (init_model_file).
#
# == Attributes
#
# [+path+] The path of the file on Dropbox. This and the user uniquely identifies any file on Fabbit.
#
# == Associations
#
# Has many:
# - Version
#
# Belongs to:
# - Member


class ModelFile < ActiveRecord::Base
  attr_accessible :cached_revision, :path

  # TODO cached_revision should not conflict semantically with Versions
  # TODO add Project association
  # NOTE do we really need to keep track of the cached revision if we just cache the latest
  # revision regardless?
  # (since this is a dropbox revision)
  validates :path, :member_id, presence: true

  has_many :versions, dependent: :destroy
  belongs_to :member


  # Retrieves the latest version of the model file by comparing the stored
  # revision number with the one on Dropbox.
  # If the stored revision is up to date, returns the file data from the cache;
  # otherwise, requests the file from Dropbox, updates the cache, revises the
  # cached revision number, and returns the file.
  #
  # The test_rev argument is used for testing to simulate a revision number
  # from dropbox. Similarly, the test_content simulates the contents of a file
  # loaded from dropbox.
  #
  # *NOTE:* May become obsolete due to use of versions instead

  def update_and_get(dropbox_client, test_rev=nil, test_content=nil)
    dropbox_rev = test_rev || dropbox_client.metadata(self.path)["rev"]
    if self.cached_revision == dropbox_rev and File.exists?(self.cache_file_name)
      return load_cached
    else
      latest_file = test_content || dropbox_client.get_file(self.path)
      cache(latest_file, dropbox_rev)
      self.cached_revision = dropbox_rev
      self.save
      return latest_file # return file
    end
  end

  # Create a file name for the cache that should not conflict with any other files.
  # If a revision is given, uses it instead of its own cached revision number.
  def cache_file_name(revision=nil)
    file_name = self.path.split("/")[-1]
    cache_folder = "cache"
    Rails.root.join(cache_folder,"#{self.member.dropbox_uid}_#{revision || self.cached_revision}_#{file_name}")
  end

  # Shortcut for the latest version of a file
  def latest_version
    self.versions.order("created_at DESC").limit(1)
  end

  # Find a version using a Dropbox revision number
  def version(revision_number)
    self.versions.find_by_revision_number(revision_number)
  end

  private

    # Load the contents of the cached file
    def load_cached
      File.open(cache_file_name, "rb") { |f| f.read }
    end

    # Write the given file contents to the cache
    def cache(content, revision)
      File.open(cache_file_name(revision), "wb") { |f| f.write(content) }
    end

end
