# == Description
#
# Controller for the home page.

class HomeController < ApplicationController

  skip_before_filter :live_dropbox_session
  skip_before_filter :refresh_name

  # Renders home page or redirects to root folder if already logged in
  def home
    # redirect_to navigate_path if cookies[:dropbox_session] and dropbox_session.authorized? and current_member?
  end

  def help
  end

end
