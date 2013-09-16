# == Schema Information
#
# Table name: model_files
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  path       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe ModelFile do

  let(:member) { FactoryGirl.create(:member) }
  let(:model_file) { FactoryGirl.create(:model_file, member: member) }
  let(:first_version) { FactoryGirl.create(:version, model_file: model_file) }

  subject { model_file }

  describe "responses" do
    it { should respond_to :path }
    it { should respond_to :cached_revision }
    it { should respond_to :latest_version }
    it { should respond_to :content }

    it { should respond_to :versions }
    it { should respond_to :projects }
    it { should respond_to :member }
  end

  describe "validations" do

    describe "sanity check" do
      it { should be_valid }
    end

    describe "with blank path" do
      before { model_file.path = "" }
      it { should_not be_valid }
    end

    describe "with blank member" do
      before { model_file.member_id = "" }
      it { should_not be_valid }
    end

  end

  describe "methods" do

    describe "latest_version" do

      let!(:new_version) do
        FactoryGirl.create(
          :version,
          revision_date: first_version.revision_date + 1.day,
          model_file: model_file
        )
      end

      it "should retrieve the latest version" do
        model_file.latest_version.should == new_version
      end

      it "should not change on non-Dropbox updates" do
        first_version.save!
        model_file.latest_version.should == new_version
      end
    end
  end

end
