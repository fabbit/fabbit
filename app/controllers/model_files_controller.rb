class ModelFilesController < ApplicationController

  before_filter :live_dropbox_session

  def show
    model_file = ModelFile.find(params[:id])
    @model = model_file
    @file = model_file.update_and_get(dropbox_client)
    @model = model_file
    @breadcrumbs = to_breadcrumbs(model_file.path)
  end

  # Loads the requested model file, initializing the file cache if necessary.
  # Redirects immediately to a RESTful model file show page
  def init_model_file
    model_file = ModelFile.where(
      user: dropbox_client.account_info["uid"].to_s,
      path: params[:filename],
    ).first_or_initialize

    if model_file.new_record? and model_file.save
      model_file.update_and_get(dropbox_client)
      model_file.revisions.create!(revision_number: model_file.cached_revision)
    end


    redirect_to model_file
  end

  def contents
    @file = ModelFile.find(params[:id]).update_and_get(dropbox_client)
    respond_to do |format|
      format.text { render text: @file }
    end
  end

  # TODO file history

end
