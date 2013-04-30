class ModelFilesController < ApplicationController

  def show
    @model = ModelFile.find(params[:id])
    @member = params[:member_id] ? Member.find(params[:member_id]) : current_member
    @file = @model.update_and_get(dropbox_client)
    @breadcrumbs = to_breadcrumbs(@model.path, @member)
  end

  # Loads the requested model file, initializing the file cache if necessary.
  # Redirects immediately to a RESTful model file show page
  def init_model_file
    member = Member.where(
      dropbox_uid: dropbox_client.account_info["uid"].to_s
    ).first_or_initialize

    if member.save
      model_file = ModelFile.where(
        member_id: member.id,
        path: params[:filename],
      ).first_or_initialize

      if model_file.new_record? and model_file.save
        model_file.update_and_get(dropbox_client)
        model_file.versions.create!(
          revision_number: model_file.cached_revision,
          details: "First version",
          revision_date: DateTime.now)
      end

      redirect_to model_file_path(model_file)
    end

  end

  def contents
    @file = ModelFile.find(params[:id]).update_and_get(dropbox_client)
    respond_to do |format|
      format.text { render text: @file }
    end

  end

  def dropbox_revisions
    @model_file = ModelFile.find(params[:id])
    @versions = @model_file.versions
    @dropbox_revisions = dropbox_client.revisions(@model_file.path)
  end

  # TODO file history

end
