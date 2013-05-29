# == Schema Information
#
# Table name: projects
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  project_type_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
#
# == Description
# A Project is a collection of ModelFiles that are relavant to the project.
#
# == Attributes
# [+name+] The name of the project
#
# == Associations
#
# Has many:
# - Member
#
# Belongs to:
# - ProjectType

class Project < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true

  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members

  belongs_to :project_type
end
