class Annotation < ActiveRecord::Base
  # TODO remove text
  attr_accessible :camera, :coordinates, :text

  validates :version_id, :member_id, :camera, :coordinates, presence: true

  belongs_to :version
  belongs_to :member
  has_many :discussions, dependent: :destroy
end
