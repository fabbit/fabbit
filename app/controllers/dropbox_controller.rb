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
      ).first_or_create!

      flash[:success] = "You've signed into Dropbox!"
      redirect_to user_navigate_path(user)
    end
  end

  def navigate
    user = User.find(params[:user_id])
    path = parse_path(params[:path], params[:more_path])
    meta = dropbox_client.metadata(path)
    @breadcrumbs = to_breadcrumbs(meta["path"])
    @contents = process_contents(meta["contents"], user)
  end

end
