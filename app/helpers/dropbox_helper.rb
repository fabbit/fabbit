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
    DropboxSession.deserialize(cookies[:dropbox_session])
  end

  def dropbox_client
    DropboxClient.new(dropbox_session, fabbit_dev_access_type)
  end

  # TODO could implement this as a cookie, saving the extra call to Dropbox
  def current_user
    @current_user = User.find_by_dropbox_uid(dropbox_client.account_info["uid"].to_s)
    @current_user.dropbox_client = dropbox_client
    return @current_user
  end

  def to_link(content)
    content[1..-1]
  end

  def parent_link(parent)
    parent
  end

  def to_filename(path)
    File.basename(path)
  end

  def parent_dir_of(path)
    path.split('/')[0..-2].join('/')
  end

  def to_breadcrumbs(path, user)
    dir_list = path.split(File::SEPARATOR)
    if !dir_list.empty? and dir_list[0].blank?
      dir_list = dir_list[1..-1]
    end
    link = ""
    dir_list.map do |crumb|
      link = File.join(link, crumb)
      { text: crumb, link: user_navigate_url(user, to_link(link)) }
    end
  end

  def parse_path(path, more_path)
    full_path = path
    if path.nil?
      full_path = '/'
    end
    if more_path
      full_path += '/' + more_path
    end
    return full_path
  end

  def process_contents(contents, user)
    contents.map do |content|
      link = user_navigate_url(user, to_link(content["path"]))
      if not content["is_dir"]
        link = user_init_model_file_url(user, to_link(content["path"]))
      end
      { content: to_filename(content["path"]), link: link, is_dir: content["is_dir"] }
    end
  end

end
