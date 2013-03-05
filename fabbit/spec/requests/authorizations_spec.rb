require 'spec_helper'
require 'dropbox_sdk'

describe "Authorizations" do
  describe "Dropbox" do
    describe "new session" do
      before do
        dropbox_sign_in
      end
      it "should be back at the home page" do
        page.should have_content('Fabbit')
      end
      it "should have an authorized dropbox session" do
        dropbox_session.authorized?.should be_true
      end
      it "should have created a dropbox client" do
        dropbox_client.should_not be_nil
      end
    end
  end
end
