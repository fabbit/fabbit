class AnnotationsController < ApplicationController

  def create
    Annotation.create!(
      coordinates: params[:coordinates],
      camera: params[:camera],
      text: params[:text],
      revision_id: params[:revision_id]
    )
  end
end
