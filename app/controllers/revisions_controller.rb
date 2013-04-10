class RevisionsController < ApplicationController

  def index
    @model_file = ModelFile.find(params[:model_file_id])
    @revisions = @model_file.revisions
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
