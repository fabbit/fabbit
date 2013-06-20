require 'spec_helper'
require 'dropbox_sdk'

describe "Authorizations" do

  before do
    dropbox_sign_in
  end

  describe "Dropbox" do

    describe "new session" do

      it "should be back at the home page" do
        page.should have_content('Your projects')
      end

      it "should have name of the current user" do
        page.should have_content(db_test_name)
      end
    end
  end
end
