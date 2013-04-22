require 'dropbox_sdk'

class DropboxController < ApplicationController

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

      user = User.where(
        dropbox_uid: dropbox_client.account_info["uid"].to_s
      ).first_or_initialize

      user.name = dropbox_client.account_info["display_name"].to_s

      if user.save
        flash[:success] = "You've signed into Dropbox!"
        redirect_to navigate_path
      end
    end
  end

  def navigate
    user = params[:user_id]? User.find(params[:user_id]) : current_user
    path = parse_path(params[:path], params[:more_path])
    meta = dropbox_client.metadata(path)
    @breadcrumbs = to_breadcrumbs(meta["path"], user)
    @contents = process_contents(meta["contents"], user)
  end

end
