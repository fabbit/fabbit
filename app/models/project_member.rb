# == Schema Information
#
# Table name: project_members
#
#  id         :integer          not null, primary key
#  project_id :integer
#  member_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
#
# == Description
#
# An association class for the many-to-many relationship between the models Member and Project
#
# == Associations
#
# Belongs to:
# - Member
# - Project

class ProjectMember < ActiveRecord::Base
  validates :member_id, :project_id, presence: true

  belongs_to :member
  belongs_to :project
end
