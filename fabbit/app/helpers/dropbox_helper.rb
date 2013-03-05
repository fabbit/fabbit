module DropboxHelper

  def fabbit_dev_app_key
    '5t1i49pjqfkm2ka'
  end

  def fabbit_dev_app_secret
    '3iu7st277c8btlb'
  end

  def fabbit_dev_access_type
    :app_folder
  end

  def dropbox_session
    DropboxSession.deserialize(session[:dropbox_session])
  end

  def dropbox_client
    DropboxClient.new(dropbox_session, fabbit_dev_access_type)
  end

  def to_link(content)
    content["path"][1..-1]
  end

  def parent_link(parent)
    parent
  end

end
