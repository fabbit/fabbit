require 'spec_helper'

describe "Home" do
  subject { page }
  before { visit root_path }

  describe "sanity tests" do
    it { should have_selector("h1", text: "Fabbit") }
  end
end
