class ApplicationController < ActionController::Base
  protect_from_forgery
  include DropboxHelper

  def live_dropbox_session
    redirect_to new_dropbox_path if !session[:dropbox_session]
  end
end
