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

      flash[:success] = "You've signed into Dropbox!"
      redirect_to navigate_path
    end
  end

  def navigate
    path = parse_path(params[:path], params[:more_path])
    meta = dropbox_client.metadata(path)
    @breadcrumbs = to_breadcrumbs(meta["path"])
    @contents = process_contents(meta["contents"])
  end

end
