# == Description
#
# Controller for the home page.

class HomeController < ApplicationController

  skip_before_filter :live_dropbox_session, :load_notifications

  # Renders home page or redirects to root folder if already logged in
  def home
    # redirect if logged in
    @disable_header = true
  end

  def help
  end

end
