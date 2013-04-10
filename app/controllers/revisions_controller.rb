class RevisionsController < ApplicationController

  def show
    @revision = Revision.find(params[:id])
    @model_file = @revision.model_file
    @file = model_file.update_and_get(dropbox_client)
    @model = model_file
    @breadcrumbs = to_breadcrumbs(model_file.path)
  end

  def index
    @model_file = ModelFile.find(params[:model_file_id])
    @revisions = @model_file.revisions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)
  end

  def show
    revision = Revision.find(params[:id])
  end

  def create
    model_file = ModelFile.find(params[:model_file_id])
  end

  def destroy
  end

end
