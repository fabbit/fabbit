class AnnotationsController < ApplicationController

  def index
    model_file = ModelFile.find(params[:model_file_id])
    version = params[:version_id] ? Version.find(params[:version_id]) : model_file.versions.first
    @annotations = version.annotations
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      format.json do
        render json: @annotations.to_json(include: { discussions: { methods: :member_name } })
      end
    end
  end

  def create
    member = Member.find_by_dropbox_uid(dropbox_client.account_info["uid"].to_s)

    model_file = ModelFile.find(params[:model_file_id])
    version = model_file.versions.first
    version = Version.find(params[:version_id]) if params[:version_id]
    @annotation = version.annotations.build(
      coordinates: params[:coordinates],
      camera: params[:camera],
      text: params[:text],
    )

    @annotation.member = member
    if @annotation.save
      respond_to do |format|
        format.js { render text: @annotation.id }
      end
    end
  end

end
