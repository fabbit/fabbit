require 'dropbox_sdk'

class DropboxController < ApplicationController

  def new
    if not params[:oauth_token]
      dbsession = DropboxSession.new(fabbit_dev_app_key, fabbit_dev_app_secret)
      dbsession.get_request_token
      session[:dropbox_session] = dbsession.serialize
      redirect_to dbsession.get_authorize_url url_for(action: 'new')
    else
      dbsession = dropbox_session
      dbsession.get_access_token
      session[:dropbox_session] = dbsession.serialize

      flash[:success] = "You've signed into Dropbox!"
      redirect_to navigate_path
    end
  end

  def navigate
    path = params[:path]
    if params[:path].nil?
      path = '/'
    end
    if params[:more_path]
      path += '/' + params[:more_path]
    end
    meta = dropbox_client.metadata(path)
    @meta = meta
    @parent = parent_dir_of path
    @folder = meta["path"]
    @contents = meta["contents"].map do |content|
      link = navigate_url(to_link(content))
      if not content["is_dir"]
        link = initialize_url(to_link(content))
      end
      { content: to_link(content), link: link, is_dir: content["is_dir"] }
    end
  end

end
