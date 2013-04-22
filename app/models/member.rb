class Member < ActiveRecord::Base
  attr_accessible :dropbox_uid, :name

  validates :dropbox_uid, :name, presence: true

  has_many :discussions, dependent: :destroy

  has_many :project_members, dependent: :destroy
  has_many :projects, through: :project_members
end
