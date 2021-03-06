require 'dropbox_sdk'

# == Description
#
# Controller for handling interactions with Dropbox.

class DropboxController < ApplicationController

  skip_before_filter :live_dropbox_session, :load_notifications, only: :new
  before_filter :clear_breadcrumbs, only: [:navigate]

  # Connects Fabbit to a Dropbox account and start the session.
  # Creates a new Member or find the corresponding member, and assign it to current_member.
  def new
    if params[:code].nil?
      redirect_to dropbox_session.start
    else

      result = dropbox_session.finish(params) # this returns [access_token, uid]
      access_token = result[0]
      uid = result[1]

      # Save the access token
      cookies[:access_token] = access_token

      # Look up or create a Member
      member = Member.where(
        dropbox_uid: uid.to_s
      ).first_or_initialize

      # Update/assign name
      member.name = dropbox_client.account_info["display_name"].to_s

      if member.save
        flash[:success] = "You've signed into Dropbox!"
        redirect_to navigate_path
      else
        flash[:error] = "Something went wrong while loading your account."
        redirect_to root_path
      end
    end
  end

  # Parses directory path from URL to display and navigate through the current member's Dropbox.
  #
  # === Variables
  # - @contents: return value of Dropbox content call, processed
  # - @projects: the projects that the member is part of
  # - @new_project: variable to hold a new project
  #
  # == Notes
  # - generates breadcrumbs using the Breadcrumbs module

  def navigate
    member = current_member
    path = params[:dropbox_path] || "/" # For root folder access, the params will be nil
    meta = dropbox_client.metadata(path)

    @contents = process_contents(meta["contents"])

    @projects = current_member.projects
    @new_project = Project.new

    make_directory_breadcrumbs(meta["path"]) # breadcrumbs
  end

  # Recursively get information on all directories.
  # Used for the add files UI.
  #
  # == Variables
  # - @directories: An array of content hashes. Content hashes contain the following:
  #   - path: the path of the content
  #   - is_dir: true if the content is a directory
  #   - content: another array of content; exists only if is_dir is true
  #   - in_project: flag for if the content is a model file and is already in a project.
  #     Requires access from a /projects/:id URL.
  def directories
    @project = Project.find(params[:project_id])
    @directories = get_dir_info("/", params[:project_id], @project)

    respond_to do |format|
      format.js
    end
  end

  # Sign out of the application
  def signout
    sign_out
    redirect_to root_path
  end

  private # Helper methods for this controller

    # Helper for property formatting a directory to a link.
    def to_link(content)
      content[0] == File::SEPARATOR ? content[1..-1] : content
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

        # If this is a file
        if not content["is_dir"]
          link = init_model_file_url(to_link(content["path"]))
          model_file = current_member.model_files.where(path: to_link(content["path"])).first

          if model_file
            model_file_id = model_file.id
          end
        end

        {
          name: File.basename(content["path"]),
          link: link,
          is_dir: content["is_dir"],
          model_file_id: model_file_id,
        }
      end
    end

    # Recursively get information from the given path
    def get_dir_info(path="/", project_id=nil, project=nil)
      dropbox_content = dropbox_client.metadata(path)

      content = Hash.new
      content[:path] = to_link(dropbox_content["path"])
      content[:name] = File.basename(content[:path])
      content[:name] = "Your Dropbox" if content[:path].blank?

      content[:is_dir] = dropbox_content["is_dir"]

      if project_id
        project ||= Project.find(project_id)
        model_file = ModelFile.where(path: content[:path]).first

        content[:in_project] = project.model_files.include?(model_file)
      end

      if content[:is_dir]
        content[:content] = Array.new
        dropbox_content["contents"].each do |item|
          content[:content] << get_dir_info(item["path"], project_id, project)
        end
      end

      return content
    end

  # end private

end
