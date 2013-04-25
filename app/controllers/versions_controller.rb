class VersionsController < ApplicationController

  def show
    @version = Version.find(params[:id])
    @model= @version.model_file
    @file = @version.retrieve_from_dropbox(dropbox_client)
    @model = @model_file
    @member = params[:member_id]? Member.find(params[:member_id]) : current_member
    @breadcrumbs = to_breadcrumbs(@model_file.path, @member)
  end

  def index
    @model_file = ModelFile.find(params[:model_file_id])
    @versions = @model_file.versions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)

    respond_to do |format|
      format.json { render json: @versions }
    end
  end

  def create
    model_file = ModelFile.find(params[:model_file_id])
    version = model_file.versions.build(revision_number: params[:revision_number])
    if version.save
      respond_to do |format|
        format.js { render text: version.id }
      end
    end
  end

  def destroy
    Version.find(params[:id]).destroy
    respond_to { |format| format.js }
  end

end
