class ModelFile < ActiveRecord::Base
  attr_accessible :cached_revision, :path, :user

  # TODO cached_revision should not conflict semantically with Revisions
  # (since this is a dropbox revision)
  validates :path, :cached_revision, :user, presence: true

  has_many :revisions, dependent: :destroy


  # Retrieves the latest version of the model file by comparing the stored
  # revision number with the one on Dropbox.
  # If the stored revision is up to date, returns the file data from the cache;
  # otherwise, requests the file from Dropbox, updates the cache, revises the
  # cached revision number, and returns the file.
  #
  # The test_rev argument is used for testing to simulate a revision number
  # from dropbox. Similarly, the test_content simulates the contents of a file
  # loaded from dropbox.

  def update_and_get(dropbox_client, test_rev=nil, test_content=nil)
    dropbox_rev = test_rev || dropbox_client.metadata(self.path)["revision"]
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
    Rails.root.join(cache_folder,"#{self.user}_#{revision || self.cached_revision}_#{file_name}")
  end

  # def latest_revision
  #   self.revisions.sort_by { |revision| revision.revision_number }.reverse[0]
  # end

  # def revision(revision_number)
  #   self.revisions.find_by_revision_number(revision_number)
  # end

  private

    # Load the contents of the cached file
    def load_cached
      File.open(cache_file_name, "rb") { |f| f.read }
    end

    # Write the given file contents to the cache
    def cache(content, revision)
      File.open(cache_file_name(revision), "w") { |f| f.write(content) }
    end

end
