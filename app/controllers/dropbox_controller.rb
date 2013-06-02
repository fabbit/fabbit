require 'dropbox_sdk'

# == Description
#
# Controller for handling interactions with Dropbox.

class DropboxController < ApplicationController

  skip_before_filter :live_dropbox_session, only: :new
  # avoiding redirect loop

  # Connects Fabbit to a Dropbox account and start the session.
  # Creates a new Member or find the corresponding member, and assign it to current_member.
  def new
    if not params[:oauth_token]
      dbsession = DropboxSession.new(fabbit_dev_app_key, fabbit_dev_app_secret)
      dbsession.get_request_token
      cookies[:dropbox_session] = dbsession.serialize
      redirect_to dbsession.get_authorize_url url_for(action: 'new')
    else
      dbsession = dropbox_session
      dbsession.get_access_token
      cookies[:dropbox_session] = dbsession.serialize

      member = Member.where(
        dropbox_uid: dropbox_client.account_info["uid"].to_s
      ).first_or_initialize

      # Update/assign name
      member.name = dropbox_client.account_info["display_name"].to_s

      if member.save
        flash[:success] = "You've signed into Dropbox!"
        redirect_to navigate_path
      else
        # TODO: Error
      end
    end
  end

  # Parses directory path from URL to display and navigate through the current member's Dropbox.
  def navigate
    member = current_member
    path = params[:dropbox_path] || "/"
    meta = dropbox_client.metadata(path)
    @breadcrumbs = to_breadcrumbs(meta["path"], member)
    @contents = process_contents(meta["contents"], member)
  end

end
