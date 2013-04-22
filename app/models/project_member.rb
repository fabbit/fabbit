class ProjectMember < ActiveRecord::Base
  validates :member_id, :project_id, precense: true

  belongs_to :member
  belongs_to :project
end
