class HomeController < ApplicationController
  def home
    redirect_to navigate_path if cookies[:dropbox_session] and dropbox_session.authorized?
  end
end
