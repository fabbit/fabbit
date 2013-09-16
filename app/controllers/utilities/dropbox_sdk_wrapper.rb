# This is a helper module that makes calls to the Dropbox API easier

require 'dropbox_sdk'

module DropboxSdkWrapper

  FABBIT_DEV_APP_KEY = '5t1i49pjqfkm2ka'
  FABBIT_DEV_APP_SECRET = '3iu7st277c8btlb'

  # Shortcut for accessing the active DropboxSession object
  def dropbox_session
    @dropbox_session ||= DropboxOAuth2Flow.new(
      FABBIT_DEV_APP_KEY,
      FABBIT_DEV_APP_SECRET,
      new_dropbox_url,
      cookies,
      :dropbox_session
    )
  end

  # Shortcut for accessing the active DropboxClient object
  def dropbox_client
    if cookies[:access_token] # NOTE: how to check if expired?
      @dropbox_client ||= DropboxClient.new(cookies[:access_token])
    end
  end

end
