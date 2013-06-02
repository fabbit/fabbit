# == Description
#
# Controller for the ModelFile model

class ModelFilesController < ApplicationController

  # Reads and displays a ModelFile
  def show
    @model = ModelFile.find(params[:id])
    @member = current_member
    @file = @model.update_and_get(dropbox_client)
    @breadcrumbs = to_breadcrumbs(@model.path, @member)
  end

  # Loads the requested model file, initializing the file cache if necessary.
  # Redirects immediately to a RESTful model file show page
  # - NOTE: Perhaps a loading screen should render here?
  def init_model_file
    # member = Member.where(
    #   dropbox_uid: dropbox_client.account_info["uid"].to_s
    # ).first_or_initialize

    # if member.save
    model_file = ModelFile.where(
      member_id: current_member.id,
      path: params[:filename],
    ).first_or_initialize

    if model_file.new_record? and model_file.save
      model_file.update_and_get(dropbox_client) # initialize cache
      model_file.versions.create!(
        revision_number: model_file.cached_revision,
        details: "First version",
        revision_date: DateTime.now
      )
    end

    redirect_to model_file_path(model_file)
    # end
    # TODO: all of the elses

  end

  # Returns the contents of the file
  # - NOTE: Move to a JS response for show?
  def contents
    @file = ModelFile.find(params[:id]).update_and_get(dropbox_client)
    respond_to do |format|
      format.text { render text: @file }
    end
  end

  # Retrieves all dropbox revisions for this model file
  def dropbox_revisions
    @model_file = ModelFile.find(params[:id])
    @versions = @model_file.versions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)
  end

  # TODO file history

end
