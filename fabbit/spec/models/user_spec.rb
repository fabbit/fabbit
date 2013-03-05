require 'spec_helper'

describe User do

  let (:user) { FactoryGirl.create(:user) }
  subject { user }

  describe "responses" do
    it { should respond_to :first_name }
    it { should respond_to :last_name}
    it { should respond_to :email }
    it { should respond_to :password }
    it { should respond_to :password_confirmation }
    it { should respond_to :password_digest }
    it { should respond_to :authenticate }
  end

  describe "#full_name" do
    it "adds the first and last name together" do
      user.full_name.should =~ /#{user.first_name}\s#{user.last_name}/
    end
  end

  describe "#autheticate" do
    before { user.save! }
    let(:found_user) { User.find_by_email(user.email) }

    describe "sanity check" do
      it "found a user" do
        found_user.should_not be_nil
      end

      it "found the right user" do
        found_user.should == user
      end
    end

    describe "with the right password" do
      it { should == found_user.authenticate(user.password) }
    end

    describe "with the wrong password" do
      before { user.password = "moobar" }
      it { should_not == found_user.authenticate(user.password) }
    end

    describe "with a wrong user with the same password" do
      let(:other_user) { FactoryGirl.create(:user) }
      it { should_not == other_user.authenticate(user.password) }
    end
  end

  # Validations
  describe "sanity check" do
    before { user.password_confirmation = user.password }
    it { should be_valid }
  end

  shared_examples_for "non-blank users fields" do
    it { should_not be_valid }
  end

  describe "validations" do
    describe "for first name" do
      before { user.first_name = " " }
      it_should_behave_like "non-blank users fields"
    end

    describe "for last name" do
      before { user.last_name = " " }
      it_should_behave_like "non-blank users fields"
    end

    describe "for email" do
      before { user.email = " " }
      it_should_behave_like "non-blank users fields"
    end

    describe "for password" do
      before { user.password = " " }
      it_should_behave_like "non-blank users fields"
    end

    describe "for password_confirmation" do
      before { user.password_confirmation = " " }
      it_should_behave_like "non-blank users fields"
    end

    describe "for not matching passwords" do
      before do
        user.password_confirmation = "moobar"
      end
      it { should_not be_valid }
    end

    describe "for matching passwords" do
      before do
        user.password = "foobar"
        user.password_confirmation = "foobar"
      end
      it { should be_valid }
    end
  end
end
