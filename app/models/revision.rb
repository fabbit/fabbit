class Revision < ActiveRecord::Base
  attr_accessible :model_file_id, :revision_number

  validates :model_file_id, :revision_number, presence: true

  belongs_to :model_file
  has_many :annotations, dependent: :destroy

  def retrieve_from_dropbox(dropbox_client)
    p [self.path, self.revision_number].join(", ")
    p dropbox_client.metadata(self.path)
    dropbox_client.get_file(self.path, self.revision_number)
  end

  def path
    self.model_file.path
  end
end
