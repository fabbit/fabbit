# == Schema Information
#
# Table name: model_files
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  path       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# A ModelFile corresponds to a file that a Fabbit member has used. It is generated upon accessing
# the file through Fabbit (init_model_file).
#
# == Attributes
#
# [+path+] The path of the file on Dropbox. This and the user uniquely identifies any file on Fabbit.
# [+cached_revision+] The revision number of the currently accessible cached file.
#
# == Associations
#
# Has many:
# - Version
# - Project
#
# Belongs to:
# - Member


class ModelFile < ActiveRecord::Base
  attr_accessible :cached_revision, :path

  # TODO cached_revision should not conflict semantically with Versions
  # NOTE do we really need to keep track of the cached revision if we just cache the latest
  # revision regardless?
  # (since this is a dropbox revision)
  validates :path, :member_id, presence: true

  has_many :versions, dependent: :destroy

  has_many :project_model_files, dependent: :destroy
  has_many :projects, through: :project_model_files

  belongs_to :member



  # Shortcut for the latest version of a file
  def latest_version
    self.versions.order("revision_date DESC").first
  end

  # Find a version using a Dropbox revision number
  def version(revision_number)
    self.versions.find_by_revision_number(revision_number)
  end

  # Loads the given version, or the latest version if version_id is nil.
  # Note that this searches through all Version records, so filtering must be done at the
  # controller level to prevent unauthorized access.
  def latest_or_version(version_id)
    version = Version.where(id: version_id).first || self.latest_version
  end

  # Shortcut for getting the model file's file name
  def name
    File.basename(self.path)
  end

  # Retrieve the content of this model file. Should always return the most recent revision.
  def content
    @content
  end

  # Updates the model file's content.
  def content=(content)
    @content = content
  end

  private

    # Load the contents of the cached file.
    def load_cached
      content = File.open(self.cache_file_name, "rb") { |f| f.read }
      puts("[MODEL_FILE] Loaded #{self.cache_file_name} from cache")
      return content
    end

    # Write the given file contents to the cache.
    def cache(content, revision_number)
      File.open(self.cache_file_name(revision_number), "wb") { |f| f.write(content) }
      print("[MODEL_FILE] Wrote #{self.cache_file_name(revision_number)} to cache")
    end

end
