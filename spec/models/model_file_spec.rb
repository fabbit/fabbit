# == Schema Information
#
# Table name: model_files
#
#  id              :integer          not null, primary key
#  user            :string(255)
#  path            :string(255)
#  cached_revision :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  member_id       :integer
#

require 'spec_helper'

describe ModelFile do

  let(:file) { FactoryGirl.create(:model_file) }
  subject { file }

  describe "responses" do
    it { should respond_to :path }
    it { should respond_to :cached_revision }
    it { should respond_to :member }
    it { should respond_to :latest }
    it { should respond_to :revisions }
  end

  describe "validations" do

    describe "sanity check" do
      it { should be_valid }
    end

    describe "with blank path" do
      before { file.path = "" }
      it { should_not be_valid }
    end

    describe "with blank member" do
      before { file.user = "" }
      it { should_not be_valid }
    end

    describe "with blank cached_revision field" do
      before { file.cached_revision = nil }
      it { should_not be_valid }
    end

  end

  describe "methods" do
    let(:content) { "test" }
    before { File.open(file.cache_file_name, "w") { |f| f.write(content) } }

    describe "latest" do

      describe "with same revision number" do
        it "should not return nil" do
          file.latest(file.cached_revision).should_not be_nil
        end

        it "should return the contents of the file" do
          file.latest(file.cached_revision).should == content
        end
      end

      describe "with new revision number" do
        let(:file_with_new_content) { "tmp/test" }
        let(:new_content) { content * 2 }
        before { File.open(file_with_new_content, "w+") { |f| f.write(new_content) } }

        it "should return new content with newer revision number" do
          file.latest(file.cached_revision + 1, new_content).should == IO.read(file_with_new_content)
        end

        it "should have updated its cache_revision" do
          old_cached_revision = file.cached_revision
          file.latest(file.cached_revision + 1, new_content)
          file.cached_revision.should == old_cached_revision + 1
        end
      end

    end

  end

  describe "revisions" do
    it "should have created a revision upon creation" do
      file.revisions.count.should be > 0
    end
  end

end
