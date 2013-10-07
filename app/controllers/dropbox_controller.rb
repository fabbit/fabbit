require 'dropbox_sdk'

# == Description
#
# Controller for handling interactions with Dropbox.

class DropboxController < ApplicationController

  skip_before_filter :live_dropbox_session, :load_notifications, only: :new

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

    make_navigation_breadcrumbs(meta["path"]) # breadcrumbs

    @contents = process_contents(meta["contents"])

    @projects = current_member.projects
    @new_project = Project.new
  end

  private # Helper methods for this controller

    # Build the breadcrumbs for the page
    def make_navigation_breadcrumbs(path)

      # Add root folder
      Breadcrumbs.add title: "Your Dropbox", link: navigate_url

      # Add links to directories

      dirs = path.split(File::SEPARATOR)

      full_path = ""
      dirs.each do |dir|
        if not dir.blank?
          full_path = File.join(full_path, dir)
          Breadcrumbs.add title: dir, link: navigate_url(to_link(full_path))
        end
      end
    end

    # Helper for property formatting a directory to a link.
    def to_link(content)
      content[0] == File::SEPARATOR ? content[1..-1] : content
    end

    # Extracts the filename from a given path
    def to_filename(path)
      File.basename(path)
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
          name: to_filename(content["path"]),
          link: link,
          is_dir: content["is_dir"],
          model_file_id: model_file_id,
        }
      end
    end

  # end private

end
