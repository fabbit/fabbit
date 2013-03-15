class AnnotationsController < ApplicationController

  def index
    model_file = ModelFile.find(params[:model_file_id])
    @annotations = model_file.revisions.first.annotations
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      format.json { render json: @annotations }
    end
  end

  def create
    model_file = ModelFile.find(params[:model_file_id])
    model_file.revisions.first.annotations.create!(
      coordinates: params[:pos],
      camera: params[:camera],
      text: params[:text]
    )
    respond_to do |format|
      format.html { redirect_to model_file }
      format.js {}
    end
  end

end
