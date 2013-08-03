# == Description
#
# Controller for the Version model

class VersionsController < ApplicationController

  # Loads and renders using the Version retrieve_from_dropbox method
  def show
    @version = Version.find(params[:id])
    @model = @version.model_file
    @content = @version.retrieve_from_dropbox(dropbox_client)
    @file = @content
    @member = current_member
    @breadcrumbs = to_breadcrumbs(@model.path)

    respond_to do |format|
      format.html
      format.js { render json: [@content, @version] }
    end
  end

  # Displays all versions and Dropbox revisions of a ModelFile.
  #
  # === Responses
  # - HTML: Renders the version index page
  # - JSON: returns a JSON object of all the Versions
  def index
    @model_file = ModelFile.find(params[:model_file_id])
    @model = @model_file
    @versions = @model.versions
    @dropbox_revisions = dropbox_client.revisions(@model.path)
    @member = current_member
    @breadcrumbs = to_breadcrumbs(@model.path)
    @versions = @model.versions

    @history = get_history_for(@model_file)
    p @history

    respond_to do |format|
      format.html
      format.json { render json: @versions }
    end
  end

  # Creates a new Version of a file based on a Dropbox revision.
  #
  # === Responses
  # - JS: Returns the new version's ID
  def create
    model_file = ModelFile.find(params[:model_file_id])
    @version = model_file.versions.build(
      revision_number: params[:revision_number],
      revision_date: params[:revision_date],
      details: params[:details],
    )
    if @version.save!
      @version.content = version.retrieve_from_dropbox(dropbox_client)
      cache(@version)
      respond_to do |format|
        format.js
      end
    end
  end

  # Deletes/unmarks a Version
  def destroy
    @version = Version.find(params[:id]).created
    respond_to do |format|
      format.js
    end
  end

  # Returns the contents of the Version file
  def contents
    @file = Version.find(params[:id]).retrieve_from_dropbox(dropbox_client)
    respond_to do |format|
      format.js { render text: @file }
    end
  end

end
