# == Schema Information
#
# Table name: annotations
#
#  id          :integer          not null, primary key
#  version_id  :integer
#  coordinates :string(255)
#  camera      :string(255)
#  text        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  member_id   :integer
#

require 'spec_helper'

describe Annotation do

  let(:member) { FactoryGirl.create(:member) }
  let(:model_file) { FactoryGirl.create(:model_file, member: member) }
  let(:first_version) { FactoryGirl.create(:version, model_file: model_file) }
  let(:first_annotation) { FactoryGirl.create(:annotation, version: first_version, member: member) }

  subject { first_annotation }

  describe "attributes" do

    it { should respond_to :camera, :coordinates, :text }
    it { should respond_to :member, :version }
    it { should respond_to :discussions }

    it { should_not allow_mass_assignment_of :member_id }
    it { should_not allow_mass_assignment_of :version_id }

  end

end
