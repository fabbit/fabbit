require 'spec_helper'

describe Member do

  describe "#projects" do

    let(:member) { FactoryGirl.create(:member) }
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
      member.projects.should include(project_1)
    end

    it "should be a flat array" do
      project_2.model_files << model_file_2

      member.projects.each do |item|
        item.should_not be_an(Array)
      end
    end

    it "should not have any nils" do
      project_2.model_files << model_file_2

      member.projects.should_not include(nil)
    end

    it "should not have duplicate projects" do
      project_1.model_files << model_file_2

      member.projects.count(project_1).should == 1
    end
  end
end
