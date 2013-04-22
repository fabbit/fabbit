class Project < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true

  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members

  belongs_to :project_type
end
