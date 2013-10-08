# == Description
#
# Controller for the Version model

class VersionsController < ApplicationController

  before_filter :owner_member, only: [:index, :create, :destroy]

  # Loads and renders the Version by loading its content.
  #
  # == Variables
  # - @version: the version
  # - @member: the version's owner
  def show
    @version = Version.find(params[:id])
    @member = @version.member

    Breadcrumbs.add @version
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
    respond_to do |format|
      format.js { render text: @version.content }
    end
  end

  private

    # Filter for actions requiring ownership.
    #
    # NOTE: this is a more elaborate duplicate of the one in ModelFilesControllers. The two should
    # be merged and placed in ApplicationController.
    def owner_member
      version = Version.find(params[:id]) if params[:id]
      model_file = ModelFile.find(params[:model_file_id]) if params[:model_file_id]
      if (version and version.member != current_member) or (model_file and model_file.member != current_member)
        redirect_to new_dropbox_path
      end
    end

end
