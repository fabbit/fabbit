class RevisionsController < ApplicationController

  def show
    @revision = Revision.find(params[:id])
    @model= @revision.model_file
    @file = @revision.retrieve_from_dropbox(dropbox_client)
    @model = @model_file
    @member = params[:member_id]? Member.find(params[:member_id]) : current_member
    @breadcrumbs = to_breadcrumbs(@model_file.path, @member)
  end

  def index
    @model_file = ModelFile.find(params[:model_file_id])
    @revisions = @model_file.revisions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)
  end

  def create
    model_file = ModelFile.find(params[:model_file_id])
    revision = model_file.build(revision_number: dropbox_client.revisions[0]["rev"]) # TODO change to a helper
    if revision.save
      respond_to { |format| format.js }
    end
  end

  def destroy
  end

end
