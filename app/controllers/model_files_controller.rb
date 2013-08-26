# == Description
#
# Controller for the ModelFile model

class ModelFilesController < ApplicationController

  # Reads and displays a ModelFile
  #
  # === Variables
  # - @model_file: the model file object
  # - @breadcrumbs: data for generating the navigational breadcrumbs
  def show
    @model_file = ModelFile.find(params[:id])
    @version = @model_file.latest_version
    @model = @model_file
    @model_file.content = @model_file.latest_version.content # load_cached(@model_file.latest_version)
    @member = current_member
    @breadcrumbs = to_breadcrumbs(@model_file)

    respond_to do |format|
      format.html
      format.js { render json: @model_file.to_json(methods: :content) }
    end
  end

  # Loads the requested model file, initializing the file cache if necessary.
  # Redirects immediately to a RESTful model file show page
  # - NOTE: Perhaps a loading screen should render here?
  def init_model_file
    model_file = ModelFile.where(
      member_id: current_member.id,
      path: params[:filename],
    ).first_or_initialize

    version = nil
    if (model_file.new_record? or model_file.versions.count == 0) and model_file.save
      version = model_file.versions.create!(
        revision_number: dropbox_client.metadata(model_file.path)["rev"],
        details: "First version",
        revision_date: DateTime.now
      )

      version.file = File.open(write_to_temp(dropbox_client.get_file(version.path)), "rb") # cache(@version)
      version.save
    end

    redirect_to model_file_path(model_file)

  end

  # Returns the content of the file
  # *NOTE:* Moved to JS response under show
  def contents
    model_file = ModelFile.find(params[:id])
    model_file.content = model_file.latest_version.content # load_cached(model_file.latest_version)
    respond_to do |format|
      format.js { render text: model_file.content }
    end
  end

  # Renders a revision of a ModelFile that has not been turned into a Version.
  # *NOTE: DEPRECATED*; see DropboxRevisionsController#show
  def preview
    model_file = ModelFile.find(params[:id])
    revision_number = params[:revision_number]
    content = dropbox_client.get_file(model_file.path, revision_number)
    p "[PREVIEW] Retrieved revision #{revision_number} from Dropbox"
    respond_to do |format|
      format.js { render text: content }
    end
  end

  # Retrieves all dropbox revisions for this model file
  # *NOTE: DEPRECATED*; see DropboxRevisionsController#index
  def dropbox_revisions
    @model_file = ModelFile.find(params[:id])
    @versions = @model_file.versions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)
    # TODO: helper for the revisions list
    respond_to do |format|
      format.js { render json: @dropbox_revisions }
      format.html
    end
  end

  # TODO file history

end
