# == Schema Information
#
# Table name: project_model_files
#
#  id            :integer          not null, primary key
#  project_id    :integer
#  model_file_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# == Description
#
# An association class for the many-to-many relationship between the Project and ModelFile models

class ProjectModelFile < ActiveRecord::Base
  attr_accessible :project_id, :model_file_id
  validates :project_id, :model_file_id, presence: true

  belongs_to :project
  belongs_to :model_file

  # Generate a message and a link for notifications
  def to_notification(current_member)
    member_name = self.model_file.member == current_member ? "You" : "#{self.model_file.member.name}"
    file_name = self.model_file.name
    project_name = self.project.name
    {
      message: "#{member_name} added file #{file_name} to #{project_name}",
      link: "/model_files/#{self.model_file.id}",
      time: self.created_at,
    }
  end
end
