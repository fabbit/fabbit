require 'spec_helper'
require 'dropbox_sdk'

describe "Authorizations" do

  before do
    dropbox_sign_in
  end
  describe "Dropbox" do
    describe "new session" do
      it "should be back at the home page" do
        page.should have_content('Fabbit')
      end
    end
  end
end
