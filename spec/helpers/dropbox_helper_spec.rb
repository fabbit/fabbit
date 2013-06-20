require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the DropboxHelper. For example:
#
# describe DropboxHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe DropboxHelper do
  describe "#to_link" do
    let(:root_dir) { "path" }
    let(:paths) { [
      "/#{root_dir}/for/testing",
      "#{root_dir}/for/testing",
    ] }

    it "should not start with a backslash" do
      paths.each do |path|
        to_link(path).should match(/^#{root_dir}/)
      end
    end
  end

  describe "#to_breadcrumbs" do
    let(:dir) { random_directory }

    it "should break down each directory in order" do
      breadcrumbs = to_breadcrumbs(dir[:path])
      breadcrumbs.map {|crumb| crumb[:text] }.should == dir[:dirs]
    end
  end
end
