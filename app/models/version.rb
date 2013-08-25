# == Schema Information
#
# Table name: versions
#
#  id              :integer          not null, primary key
#  model_file_id   :integer
#  revision_number :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  details         :string(255)
#  revision_date   :datetime
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
    @content
  end

  def content=(content)
    @content = content
  end
end
