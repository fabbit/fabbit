# == Description
#
# Controller for the ModelFile model

class ModelFilesController < ApplicationController

  # Displays information about a ModelFile
  #
  # === Variables (TODO)
  def show
    @model_file = ModelFile.find(params[:id])
    @model = @model_file
    @versions = @model.versions
    @dropbox_revisions = dropbox_client.revisions(@model.path)
    @member = current_member
    @breadcrumbs = to_breadcrumbs(@model)
    @versions = @model.versions
    @projects = Project.all
    @history = get_history_for(@model_file)
    @full_version_view = false

    respond_to do |format|
      format.html
      format.json { render json: @versions }
    end
  end

  # Loads the requested model file
  # Redirects immediately to a RESTful model file show page
  # - NOTE: Perhaps a loading screen should render here?
  def init_model_file
    model_file = ModelFile.where(
      member_id: current_member.id,
      path: params[:filename],
    ).first_or_initialize

    version = nil
    meta = dropbox_client.metadata(model_file.path)
    if (model_file.new_record? or model_file.versions.count == 0) and model_file.save
      version = model_file.versions.create!(
        revision_number: meta["rev"],
        details:         "First version",
        revision_date:   meta["modified"].to_datetime
      )

      version.content = dropbox_client.get_file(version.path)
    end


    version = model_file.latest_version
    redirect_to version_path(version)

  end

  private 

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
    
end
