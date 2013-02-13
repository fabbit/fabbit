require 'spec_helper'

describe "Home" do
  subject { page }
  before { visit root_path }

  describe "sanity tests" do
    it { should have_content("home") }
  end
end
