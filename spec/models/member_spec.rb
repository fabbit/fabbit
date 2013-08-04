# == Schema Information
#
# Table name: members
#
#  id          :integer          not null, primary key
#  dropbox_uid :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#

require 'spec_helper'

describe Member do

  let(:member) { FactoryGirl.create(:member) }

  describe "#participating_participating_projects" do

    let(:model_file_1) { FactoryGirl.create(:model_file, member: member) }
    let(:model_file_2) { FactoryGirl.create(:model_file, member: member) }
    let(:version) { FactoryGirl.create(:version, model_file: model_file) }
    let(:project_type) { FactoryGirl.create(:project_type) }
    let(:project_1) { FactoryGirl.create(:project, project_type: project_type) }
    let(:project_2) { FactoryGirl.create(:project, project_type: project_type) }

    before do
      project_1.model_files << model_file_1
    end

    it "should return project if project has a member's model_file" do
      member.participating_projects.should include(project_1)
    end

    it "should be a flat array" do
      project_2.model_files << model_file_2

      member.participating_projects.each do |item|
        item.should_not be_an(Array)
      end
    end

    it "should not have any nils" do
      project_2.model_files << model_file_2

      member.participating_projects.should_not include(nil)
    end

    it "should not have duplicate participating_projects" do
      project_1.model_files << model_file_2

      member.participating_projects.count(project_1).should == 1
    end
  end

  describe "groups" do

    let(:group) { FactoryGirl.create(:group) }

    subject { member }

    it { should respond_to :groups }
    it { should respond_to :accessible_projects }

    describe "auto add to default group" do


      before do
        group.save
        member.save
      end

      it "should have been added to the first group by default" do
        member.groups.first.should == group
      end
    end

  end

end
