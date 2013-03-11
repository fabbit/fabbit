class ModelFilesController < ApplicationController

  def show
    model_file = ModelFile.find(params[:id])
    model_file.client = dropbox_client
    @parent = model_file.path.split('/')[0..-2]
    @modelname = model_file.path.split('/').last
    @file = model_file.latest
  end

  def init_model_file
    model_file = ModelFile.where(
      user: dropbox_client.account_info["uid"],
      path: params[:filename],
      cached_revision: dropbox_client.metadata(params[:filename])["revision"]
    ).first_or_initialize
    model_file.client = dropbox_client
    model_file.save
    redirect_to model_file
  end
end
