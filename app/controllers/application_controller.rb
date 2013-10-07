# Load controller helpers
require 'utilities/dropbox_sdk_wrapper'
require 'utilities/breadcrumbs'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include DropboxHelper
  include NotificationsHelper
  include DropboxSdkWrapper

  helper Breadcrumbs

  helper_method :current_member, :sign_out

  before_filter :live_dropbox_session, :load_notifications, :clear_breadcrumbs

  # == View helper methods

  # Returns the Member corresponding to the active Dropbox user
  def current_member
    begin
      @dropbox_uid ||= dropbox_client.account_info["uid"].to_s
      @current_member ||= Member.where(dropbox_uid: @dropbox_uid).first
    rescue DropboxError
      sign_out
    end
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
    redirect_to new_dropbox_path if current_member.nil?
  end

  # Filter for loading notifications on each page for the header
  def load_notifications
    @notifications = current_member.notifications(1, nil, false)
  end

  # Clear breadcrumbs on refresh
  # TODO: handle module-side
  def clear_breadcrumbs
    Breadcrumbs.clear
  end

  # == Controller helpers

  # Finds the model file owned by the current_member, or initializes a new one.
  def find_or_initialize(path)
    model_file = ModelFile.where(
      member_id: current_member.id,
      path: params[:filename],
    ).first_or_initialize

    version = nil
    meta = dropbox_client.metadata(model_file.path)
    if (model_file.new_record? or model_file.versions.count == 0) and model_file.save
      version = model_file.versions.create!(
        revision_number: meta["rev"],
        details:         "First version",
        revision_date:   meta["modified"].to_datetime
      )

      version.content = dropbox_client.get_file(version.path)
    end

    return model_file
  end



end
