# == Schema Information
#
# Table name: project_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
#
# == Description
# A type indicator for a Project. Projects can have many types
#
# == Attributes
#
# [+name+] The name of the project type
#
# == Associations
#
# Has many:
# - Projects

class ProjectType < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true

  has_many :projects
end
