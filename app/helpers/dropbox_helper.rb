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
    @current_member ||= Member.where(dropbox_uid: dropbox_uid).first
  end

  def dropbox_uid
    @dropbox_uid ||= dropbox_client.account_info["uid"].to_s
  end

  # Temp folder for holding files to be sent to S3
  def temp_dir
    File.join(Rails.root, "tmp")
  end

  # Write a file to the tmp folder
  def write_to_temp(content)
    dir = File.join(temp_dir, rand_file_name)
    File.open(dir, 'wb') {|f| f.write(content) }
    return dir
  end

  # Random file name
  def rand_file_name
    (0...8).map{(65+rand(26)).chr}.join
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
  #   - This method should always be called whenever a member wants to interact with a ModelFile so
  #     that they always see the most recent revision.
  #   - This should be the *only* method that makes any modifications to a ModelFile.
  #   - Looking to be replaced by Version default caching
  def update_content_of(model_file)
    dropbox_rev = 0
    if model_file.member == current_member
      dropbox_rev = dropbox_client.metadata(model_file.path)["rev"]
    end
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

  # Formats a path (with or without a ModelFile) to be made into breadcrumbs
  # - NOTE: uses absolute path
  def to_breadcrumbs(model_file_or_path)
    path = model_file_or_path
    model_file = nil
    if model_file_or_path.instance_of? ModelFile
      path = model_file_or_path.path
      model_file = model_file_or_path
    end

    # Extract and split path
    dirname = File.dirname(path) == "." ? "" : File.dirname(path)
    dir_list = dirname.split(File::SEPARATOR).map do |x|
      x.blank? ? File::SEPARATOR : x
    end
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
      if model_file
        breadcrumbs << { text: file_name, link: init_model_file_url(to_link(path)) }
      else
        breadcrumbs << { text: file_name, link: navigate_url(to_link(path)) }
      end
    end

    return breadcrumbs
  end

  def debug_list
    @debug = Array.new if not @debug
    @debug
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
      projects = []
      model_file_id = nil
      if not content["is_dir"]
        link = init_model_file_url(to_link(content["path"]))
        model_file = current_member.model_files.where(path: to_link(content["path"])).first
        if model_file
          projects = Project.all.map do |project|
            { name: project.name,
              id: project.id,
              has_model_file: model_file.projects.include?(project),
              model_file_id: model_file.id,
              project_model_file: project.project_model_files.where(model_file_id: model_file.id).first
            }
          end
          model_file_id = model_file.id
          member = model_file.member
        end
      end
      # TODO: change to ?: format

      { content: to_filename(content["path"]),
        link: link,
        is_dir: content["is_dir"],
        projects: projects,
        model_file_id: model_file_id,
        member: member,
      }
    end
  end

  # Retrieves all Versions and Dropbox revisions for a ModelFile, returning it in a unified format.
  def get_history_for(model_file)
    versions = model_file.versions
    dropbox_revisions = dropbox_client.revisions(model_file.path)

    dropbox_revisions.map do |revision|
      version = versions.find_by_revision_number(revision["rev"])
      { id: version ? version.id : revision["rev"],
        modified: version ? version.revision_date : revision["modified"],
        version: version,
        details: version ? version.details : ""
      }
    end

  end

  # Refresh the current member's name
  def refresh_name
    if DateTime.now - current_member.updated_at.to_datetime > 1.hour
      p "Updatting"
      current_member.name = dropbox_client.account_info["display_name"]
      current_member.save
    end
  end

  # Initializes the cache for a Version
  def initialize_cache(version)
    cache(version) if version
  end

  # Create a file name for the cache that should not conflict with any other files.
  # If a revision is given, uses it instead of its own cached revision number.
  def cache_file_name_of(model_file, revision=nil)
    file_name = File.basename(model_file.path)
    cache_folder = "cache"

    # Temporary abstraction, in case a switch back is required
    if model_file.instance_of? Version
      Rails.root.join(cache_folder, model_file.id.to_s)   # NOTE: maybe want to encrypt?
    else
      Rails.root.join(cache_folder,"#{model_file.member.dropbox_uid}_#{revision || model_file.cached_revision}_#{file_name}")
    end
  end

  # Load the contents of the cached Version
  def load_cached(version)
    if !File.exists?(cache_file_name_of(version))
      cache(version)
    end

    puts("[DROPBOX_HELPER] Loading cached file #{cache_file_name_of(version)}...")
    File.open(cache_file_name_of(version), "rb") { |f| f.read }
  end

  # Write the contents of a Version to the cache.
  def cache(version)
    File.open(cache_file_name_of(version), "wb") { |f| f.write(dropbox_client.get_file(version.path)) }
    puts("[DROPBOX_HELPER] Wrote #{cache_file_name_of(version)} to cache")
  end

end
