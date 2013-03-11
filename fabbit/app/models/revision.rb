class Revision < ActiveRecord::Base
  attr_accessible :model_file_id, :revision_number

  validates :model_file_id, :revision_number, presence: true

  belongs_to :model_file
  has_many :annotations
end
