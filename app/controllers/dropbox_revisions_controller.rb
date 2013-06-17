class DropboxRevisionsController < ApplicationController
  # Renders a revision of a ModelFile that has not been turned into a Version.
  def show
    model_file = ModelFile.find(params[:model_file_id])
    revision_number = params[:id]
    revision = dropbox_client.get_file_and_metadata(model_file.path, revision_number)
    p "[PREVIEW] Retrieved revision #{revision_number} from Dropbox"
    respond_to do |format|
      format.js { render json: revision }
    end
  end

  # Retrieves all dropbox revisions for this model file
  def index
    @model_file = ModelFile.find(params[:model_file_id])
    @versions = @model_file.versions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)
    # TODO: helper for the revisions list
    respond_to do |format|
      format.js { render json: @dropbox_revisions }
      format.html
    end
  end

end
