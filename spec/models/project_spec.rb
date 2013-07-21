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

require 'spec_helper'

describe Project do

  let(:project_type) { FactoryGirl.create(:project_type) }
  let(:project) { FactoryGirl.create(:project, project_type: project_type) }

  subject { project }

  describe "responses" do
    it { should respond_to :members }
  end

end
