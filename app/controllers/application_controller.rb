require 'dropbox_sdk'

class ApplicationController < ActionController::Base
  #protect_from_forgery
  include DropboxHelper

  before_filter :live_dropbox_session, :refresh_name

  # Filter for checking that the Dropbox session is still live for every request
  def live_dropbox_session
    if cookies[:dropbox_session].nil? or not dropbox_session
      redirect_to new_dropbox_path
    end
  end

end
