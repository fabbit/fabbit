# == Description
#
# Controller for the ModelFile model

class ModelFilesController < ApplicationController

  before_filter :owner_of_model_file, only: [:show]
  skip_before_filter :clear_breadcrumbs, only: [:init_model_file]

  # Displays information about a ModelFile
  #
  # === Variables
  # - @model_file: the model file
  # - @revisions: the formatted set of revisions (including versions)
  # - @projects: the projects that the user can add the model_file to
  def show
    @model_file = ModelFile.find(params[:id])
    @projects = current_member.projects
    @revisions = get_revisions_for(@model_file)
  end

  # Loads the requested model file
  # Redirects immediately to a RESTful model file show page
  # - NOTE: Perhaps a loading screen should render here?
  def init_model_file
    model_file = find_or_initialize(params[:filename])

    redirect_to model_file.latest_version
  end

  private

    # Retrieves all Versions and Dropbox revisions for a ModelFile, returning it in a unified format.
    #
    # The format is a hash with the following values:
    # - id: the id of the version, or the revision number if the revision is not a version
    # - modified: the last modified time of the revision
    # - version: the version object for the revision. nil if not a version
    # - details: the details of the version. blank if not a version
    def get_revisions_for(model_file)
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

    # Filter to check for ownership
    def owner_of_model_file
      redirect_to root_path unless current_member.owns?(ModelFile.find(params[:id]))
    end

  # end private
end
