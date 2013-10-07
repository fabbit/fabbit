# == Description
#
# Controller for the Version model

class VersionsController < ApplicationController

  before_filter :owner_member, only: [:index, :create, :destroy]

  # Loads and renders using the Version retrieve_from_dropbox method
  def show
    @version = Version.find(params[:id])
    @model_file = @version.model_file
    @model_file.content = @version.content
    @member = current_member

    Breadcrumbs.add @version

    @full_version_view = true;
    respond_to do |format|
      format.html
      format.js { render json: [@content, @version] }
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
      @version.content = dropbox_client.get_file(@version.path)
      @version.save

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
    @version = Version.find(params[:id])
    @file = @version.content
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
