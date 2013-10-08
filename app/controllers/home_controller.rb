# == Description
#
# Controller for the home page.

class HomeController < ApplicationController

  skip_before_filter :live_dropbox_session, :load_notifications

  # Renders home page
  def home
    @disable_header = true
  end

end
