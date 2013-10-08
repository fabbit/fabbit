require 'utilities/dropbox_sdk_wrapper'
require 'utilities/breadcrumbs'

# == Description
#
# The main application controller. Contains mostly helper methods and modules, as well as
# application-wide filters.

class ApplicationController < ActionController::Base
  protect_from_forgery

  include DropboxHelper
  include NotificationsHelper
  include DropboxSdkWrapper

  helper Breadcrumbs

  helper_method :debug_list, :current_member, :sign_out, :timestamp

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

  # List of things to inspect when debugging
  def debug_list
    @debug ||= Array.new
  end

  # Formatted time stamp with options
  #
  # Options:
  # - field: the name of the time field. default is created_at.
  # - length: can be either long or short. default is long.
  # - only: time or date. default is neither.
  def timestamp(model, options={})
    datetime = options[:field] ? model.send(options[:field]) : model.created_at

    time = datetime.strftime("%l:%M %p")
    date = datetime.strftime("%a. %-m/%-d, %Y")

    if options[:length] == :short
      time = datetime.strftime("%H:%M")
      date = datetime.strftime("%-m-%-d-%y")
    end

    if options[:only] == :time
      return time
    elsif options[:only] == :date
      return date
    else
      return "#{date} #{time}"
    end
  end

  # == Filters

  # Filter for checking that the Dropbox session is still live for every request
  def live_dropbox_session
    redirect_to new_dropbox_path if current_member.nil?
  end

  # Filter for loading notifications on each page for the header
  def load_notifications
    @notifications = current_member.notifications
  end

  # Clear breadcrumbs on refresh
  # TODO: handle module-side
  def clear_breadcrumbs
    Breadcrumbs.clear
  end

  # Filter for admin-only actions
  def admin_member
    redirect_to root_path if current_member.admin?
  end

  # == Controller helpers

  # Finds the model file owned by the current_member, or initializes a new one.
  def find_or_initialize(path)
    model_file = ModelFile.where(
      member_id: current_member.id,
      path: path,
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

  # Build the breadcrumbs for a directory from a path
  def make_directory_breadcrumbs(path)

    # Add root folder
    Breadcrumbs.add title: "Your Dropbox", link: navigate_url

    # Add links to directories

    dirs = path.split(File::SEPARATOR)

    full_path = ""
    dirs.each do |dir|
      if not dir.blank?
        full_path = File.join(full_path, dir)
        Breadcrumbs.add title: dir, link: navigate_url(to_link(full_path))
      end
    end
  end



end
