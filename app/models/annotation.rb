class Annotation < ActiveRecord::Base
  # TODO remove text
  attr_accessible :camera, :coordinates, :revision_id, :text

  validates :revision_id, :member_id, :camera, :coordinates, presence: true

  belongs_to :revision
  belongs_to :member
  has_many :discussions, dependent: :destroy
end
