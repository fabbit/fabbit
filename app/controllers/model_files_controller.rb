class ModelFilesController < ApplicationController

  before_filter :live_dropbox_session

  def show
    model_file = ModelFile.find(params[:id])
    model_file.dropbox = dropbox_client
    @model = model_file
    @parent = model_file.path.split('/')[0..-2]
    @modelname = model_file.path.split('/').last
    @file = model_file.latest
    @revision = model_file.revisions.first
    @model = model_file
  end

  def init_model_file
    model_file = ModelFile.where(
      user: dropbox_client.account_info["uid"].to_s,
      path: params[:filename],
      cached_revision: dropbox_client.metadata(params[:filename])["revision"]
    ).first_or_initialize
    if model_file.new_record?
      p "\n\nadfasdfsad\n\n"
    end
    model_file.dropbox = dropbox_client
    model_file.save
    redirect_to model_file
  end

  # TODO file history

end
