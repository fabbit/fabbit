class AnnotationsController < ApplicationController

  def index
    model_file = ModelFile.find(params[:model_file_id])
    revision = model_file.revisions.first
    revision = Revisions.find(params[:revision_id]) if params[:revision_id]
    @annotations = revision.annotations
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      format.json { render json: @annotations.to_json(include: :discussions) }
    end
  end

  def create
    user = User.where(
      dropbox_uid: dropbox_client.account_info["user_id"].to_s
    )

    model_file = ModelFile.find(params[:model_file_id])
    revision = model_file.revisions.first
    revision = Revisions.find(params[:revision_id]) if params[:revision_id]
    @annotation = revision.annotations.create!(
      coordinates: params[:coordinates],
      camera: params[:camera],
      text: params[:text],
      user_id: user.id
    )
    respond_to do |format|
      format.js { render text: @annotation.id }
    end
  end

end
