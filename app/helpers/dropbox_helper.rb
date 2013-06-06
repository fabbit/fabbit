module DropboxHelper

  FABBIT_DEV_APP_KEY = '5t1i49pjqfkm2ka'
  FABBIT_DEV_APP_SECRET = '3iu7st277c8btlb'
  FABBIT_DEV_ACCESS_TYPE = :app_folder

  # Returns the Fabbit app key from Dropbox
  # - NOTE: Shouldn't this be a constant?
  def fabbit_dev_app_key
    '5t1i49pjqfkm2ka'
  end

  # Returns the Fabbit app secret from Dropbox
  def fabbit_dev_app_secret
    '3iu7st277c8btlb'
  end

  # Returns the Fabbit app access type for Dropbox
  def fabbit_dev_access_type
    :app_folder
  end

  # Shortcut for accessing the active DropboxSession object
  def dropbox_session
    DropboxSession.deserialize(cookies[:dropbox_session])
  end

  # Shortcut for accessing the active DropboxClient object
  def dropbox_client
    DropboxClient.new(dropbox_session, fabbit_dev_access_type)
  end

  # Returns the Member corresponding to the active Dropbox user
  # - TODO: test
  def current_member
    @current_member = Member.find_by_dropbox_uid(dropbox_client.account_info["uid"].to_s)
    @current_member.name = dropbox_client.account_info["display_name"]
    if @current_member.save
      return @current_member
    end
  end

  # Checks for a current_member
  # - NOTE: is this necessary with the addition of the live_dropbox_session global filter?
  def current_member?
    return !@current_member.nil?
  end

  # Updates the content of a ModelFile by comparing the model file's cached_revision with a revision
  # number from Dropbox and retrieving the file from Dropbox if there's a mismatch. Also updates the
  # cache.
  #
  # [+NOTE+]
  # - This method should always be called whenever a member wants to interact with a ModelFile so
  #   that they always see the most recent revision.
  # - This should be the *only* method that makes any modifications to a ModelFile.
  def update_content_of(model_file)
    dropbox_rev = dropbox_client.metadata(model_file.path)["rev"]
    if model_file.cached_revision != dropbox_rev or !File.exists?(cache_file_name_of(model_file))
      model_file.content = dropbox_client.get_file(model_file.path)   # update content
      cache(model_file, dropbox_rev)                                  # update cache
      model_file.cached_revision = dropbox_rev

      model_file.save
      puts "[DROPBOX_HELPER] Updated content of ModelFile #{model_file.id}"
    else
      puts "[DROPBOX_HELPER] ModelFile #{model_file.id} is up to date"
      model_file.content = load_cached(model_file)
    end
  end

  # Helper for property formatting a directory to a link.
  def to_link(content)
    content[0] == File::SEPARATOR ? content[1..-1] : content
  end

  # Returns the link for the parent directory
  # - NOTE: does not do anything at the moment
  def parent_link(parent)
    parent
  end

  # Extracts the filename from a given path
  def to_filename(path)
    File.basename(path)
  end

  # Returns the path of the parent directory
  # - TODO: use File split and join
  # - NOTE: do I even use this?
  def parent_dir_of(path)
    path.split('/')[0..-2].join('/')
  end

  # Formats a path to be made into breadcrumbs
  # - NOTE: uses absolute path
  def to_breadcrumbs(path)

    # Extract and split path
    dir_list = File.dirname(path).split(File::SEPARATOR).map do |x|
      x.blank? ? File::SEPARATOR : x
    end[1..-1]
    file_name = File.basename(path)

    link = ""
    breadcrumbs = []

    # Map each part of the path to a navigate_url for the corresponding directory
    if dir_list
      breadcrumbs = dir_list.map do |crumb|
        link = File.join(link, crumb) # adds onto link for each element to form a valid path
        { text: crumb, link: navigate_url(to_link(link)) }
      end
    end

    # Map the file name to an init_model_file_url
    # TODO: figure out how to figure out if the last bit is a file
    if file_name and file_name != File::SEPARATOR
      breadcrumbs << { text: file_name, link: "#" } # init_model_file_url(to_link(path)) }
    end

    return breadcrumbs
  end

  # Process the path given to navigate
  # - TODO: use File methods
  def parse_path(path)
    full_path = path
    if path.nil?
      full_path = '/'
    end
    if more_path
      full_path += '/' + more_path
    end
    return full_path
  end

  # Process the contents returned by Dropbox
  def process_contents(contents)
    contents.map do |content|
      link = navigate_url(to_link(content["path"]))
      if not content["is_dir"]
        link = init_model_file_url(to_link(content["path"]))
      end
      # TODO: change to ?: format

      { content: to_filename(content["path"]), link: link, is_dir: content["is_dir"] }
    end
  end

  private

    # Create a file name for the cache that should not conflict with any other files.
    # If a revision is given, uses it instead of its own cached revision number.
    def cache_file_name_of(model_file, revision=nil)
      file_name = File.basename(model_file.path)
      cache_folder = "cache"
      Rails.root.join(cache_folder,"#{model_file.member.dropbox_uid}_#{revision || model_file.cached_revision}_#{file_name}")
    end

    # Load the contents of the cached ModelFile
    def load_cached(model_file)
      puts("[DROPBOX_HELPER] Loading cached file #{cache_file_name_of(model_file)}...")
      File.open(cache_file_name_of(model_file), "rb") { |f| f.read }
    end

    # Write the contents of a ModelFile to the cache.
    def cache(model_file, revision_number)
      File.open(cache_file_name_of(model_file, revision_number), "wb") { |f| f.write(model_file.content) }
      puts("[DROPBOX_HELPER] Wrote #{cache_file_name_of(model_file, revision_number)} to cache")
    end

end
