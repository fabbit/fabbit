class Annotation < ActiveRecord::Base
  # TODO remove text
  attr_accessible :camera, :coordinates, :revision_id, :text

  validates :revision_id, :user_id, :camera, :coordinates, presence: true

  belongs_to :revision
  belongs_to :user
  has_many :discussions, dependent: :destroy
end
