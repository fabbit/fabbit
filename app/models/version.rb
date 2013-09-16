# == Schema Information
#
# Table name: versions
#
#  id                :integer          not null, primary key
#  model_file_id     :integer
#  revision_number   :string(255)
#  details           :string(255)
#  revision_date     :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#

# == Description
#
# A specific version of a ModelFile, with a description of its significant changes
#
# == Attributes
#
# [+revision_number+] The Dropbox-given revision number
# [+revision_date+] The date of the revision as it happened on Dropbox
# [+details+] A short description of the version changes
#
# == Associations
#
# Has many:
# - Annotation
#
# Belongs to:
# - ModelFile

class Version < ActiveRecord::Base
  attr_accessible :revision_number, :revision_date, :details

  validates :model_file_id, :revision_number, :details, :revision_date, presence: true

  belongs_to :model_file
  has_many :annotations, dependent: :destroy

  # Always order by revision_date
  default_scope order('revision_date DESC')


  # Paperclip attachment
  has_attached_file :file

  def retrieve_from_dropbox(dropbox_client)
    dropbox_client.get_file(self.path, self.revision_number)
  end

  def path
    self.model_file.path
  end

  def name
    self.model_file.name
  end

  def member
    self.model_file.member
  end

  def content
    Paperclip.io_adapters.for(self.file).read
  end

  # Write and save the contents to a temporary file, then save it to S3 using Paperclip
  def content=(content)
    temp_file = File.open(write_to_temp(content), "rb")
    self.file = temp_file
    if self.save
      return temp_file
    else
      return false
    end
  end

  private

    # Temp folder for holding files to be sent to S3
    def temp_dir
      File.join(Rails.root, "tmp")
    end

    # Write a file to the tmp folder
    def write_to_temp(content)
      dir = File.join(temp_dir, rand_file_name)
      File.open(dir, 'wb') {|f| f.write(content) }
      return dir
    end

    # Random file name
    def rand_file_name
      (0...8).map{(65+rand(26)).chr}.join
    end

  # end private

end
