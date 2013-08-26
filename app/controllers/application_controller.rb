require 'dropbox_sdk'

class ApplicationController < ActionController::Base
  #protect_from_forgery
  include DropboxHelper
  include NotificationsHelper

  before_filter :live_dropbox_session, :refresh_name, :notifications


  # Filter for checking that the Dropbox session is still live for every request
  def live_dropbox_session
    if cookies[:dropbox_session].nil? or not dropbox_session
      redirect_to new_dropbox_path
    end
  end

  def notifications
    @notifications = get_notifications
  end

end
