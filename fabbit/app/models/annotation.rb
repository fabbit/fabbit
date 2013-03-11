class Annotation < ActiveRecord::Base
  attr_accessible :camera, :coordinates, :revision_id, :text

  validates :revision_id, presence: true

  belongs_to :revision
end
