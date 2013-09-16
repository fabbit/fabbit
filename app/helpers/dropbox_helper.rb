module DropboxHelper

  # Helper for property formatting a directory to a link.
  def to_link(content)
    content[0] == File::SEPARATOR ? content[1..-1] : content
  end

  # Extracts the filename from a given path
  def to_filename(path)
    File.basename(path)
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

  # List of things to inspect when debugging
  def debug_list
    @debug = Array.new if not @debug
    @debug
  end


end
