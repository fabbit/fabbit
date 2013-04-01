class Annotation < ActiveRecord::Base
  # TODO remove text and move to a discussion model
  attr_accessible :camera, :coordinates, :revision_id, :text

  validates :revision_id, presence: true

  belongs_to :revision
end
