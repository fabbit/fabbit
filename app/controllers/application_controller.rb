# Load controller helpers
require 'utilities/dropbox_sdk_wrapper'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include DropboxHelper
  include NotificationsHelper
  include DropboxSdkWrapper

  helper_method :current_member, :sign_out

  before_filter :live_dropbox_session, :load_notifications

  # == View helper methods

  # Returns the Member corresponding to the active Dropbox user
  def current_member
    @dropbox_uid ||= dropbox_client.account_info["uid"].to_s
    @current_member ||= Member.where(dropbox_uid: @dropbox_uid).first
  end

  # Sign out of the application
  def sign_out
    @current_member = nil
    cookies[:access_token] = nil
  end

  # == Filters

  # Filter for checking that the Dropbox session is still live for every request
  # NOTE: how do I check for an expired session?
  def live_dropbox_session
    if cookies[:access_token].nil?
      sign_out
      redirect_to new_dropbox_path
    end
  end

  # == Controller helper methods

  def load_notifications
    @notifications = current_member.notifications(1, nil, false)
  end

end
