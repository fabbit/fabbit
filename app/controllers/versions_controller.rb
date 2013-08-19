# == Description
#
# Controller for the Version model

class VersionsController < ApplicationController

  before_filter :owner_member, only: [:create, :destroy]

  # Loads and renders using the Version retrieve_from_dropbox method
  def show
    @version = Version.find(params[:id])
    @model_file = @version.model_file
    @model_file.content = load_cached(@version)
    @member = current_member
    @breadcrumbs = to_breadcrumbs(@model_file)

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
    @breadcrumbs = to_breadcrumbs(@model)
    @versions = @model.versions

    @history = get_history_for(@model_file)

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

    if @version.save
      cache(@version)

      @rev = {
        id: @version.id,
        modified: @version.revision_date,
        version: @version
      }

    else
      @error = true
    end
    respond_to do |format|
      format.js do
        if @error
          render text: @version.errors.full_messages.join(", "), status: 403
        end
      end
    end
  end

  # Deletes/unmarks a Version
  def destroy
    @version = Version.find(params[:id])
    if @version.model_file.versions.count > 1
      @version.destroy
      @rev = {
        id: @version.revision_number,
        modified: @version.revision_date,
        version: nil
      }
    else
      @error = true
    end
    respond_to do |format|
      format.js do
        if @error
          render text: "Cannot delete this version", status: 403
        end
      end
    end
  end

  # Returns the contents of the Version file
  def contents
    @file = Version.find(params[:id]).retrieve_from_dropbox(dropbox_client)
    respond_to do |format|
      format.js { render text: @file }
    end
  end

  private

    # Filter for actions requiring ownership
    def owner_member
      @version = Version.find(params[:id]) if params[:id]
      @model_file = ModelFile.find(params[:model_file_id]) if params[:model_file_id]
      if (@version and @version.member != current_member) or (@model_file and @model_file.member != current_member)
        redirect_to new_dropbox_path
      end
    end


end
