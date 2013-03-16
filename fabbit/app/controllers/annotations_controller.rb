class AnnotationsController < ApplicationController

  def index
    model_file = ModelFile.find(params[:model_file_id])
    revision = model_file.revisions.first
    revision = Revisions.find(params[:revision_id]) if params[:revision_id]
    @annotations = revision.annotations
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      format.json { render json: @annotations }
    end
  end

  def create
    revision = model_file.revisions.first
    revision = Revisions.find(params[:revision_id]) if params[:revision_id]
    revision.annotations.create!(
      coordinates: params[:pos],
      camera: params[:camera],
      text: params[:text]
    )
    respond_to do |format|
      format.js
    end
  end

end
