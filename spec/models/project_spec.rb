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
  let(:group) { FactoryGirl.create(:group) }

  subject { project }

  describe "responses" do
    it { should respond_to :members }
    it { should respond_to :groups }
  end

  describe "auto add to group" do

    before do
      group.save
      project.save
    end

    it "should be part of the group by default" do
      project.groups.first.should == group
    end

  end

end
