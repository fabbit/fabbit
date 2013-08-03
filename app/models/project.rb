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

# == Description
#
# A representation of a project that can contain multiple ModelFiles
#
# == Attributes
#
# [+name+] The name of the project
#
# == Associations
#
# Has many:
# - ModelFile
# - Group
#
# Belongs to:
# - ProjectType

class Project < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true

  # has_many :project_members, dependent: :destroy
  # has_many :members, through: :project_members

  has_many :project_model_files, dependent: :destroy
  has_many :model_files, through: :project_model_files

  has_many :group_projects, dependent: :destroy
  has_many :groups, through: :group_projects

  belongs_to :project_type

  def members
    self.model_files.map { |model_file| model_file.member }.compact.uniq
  end
end
