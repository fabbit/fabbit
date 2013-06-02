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
  validates :project_id, :model_file_id, presence: true

  belongs_to :project
  belongs_to :model_file
end
