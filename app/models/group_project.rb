# == Schema Information
#
# Table name: group_projects
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# Many-to-many relationship class between the Group and Project models
#
# == Associations
#
# Belongs to:
# - Group
# - Project

class GroupProject < ActiveRecord::Base
  belongs_to :group
  belongs_to :project
end
