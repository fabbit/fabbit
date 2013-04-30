class VersionsController < ApplicationController

  def show
    @version = Version.find(params[:id])
    @model = @version.model_file
    @file = @version.retrieve_from_dropbox(dropbox_client)
    @model = @model_file
    @member = params[:member_id]? Member.find(params[:member_id]) : current_member
    @breadcrumbs = to_breadcrumbs(@model_file.path, @member)
  end

  def index
    @model = ModelFile.find(params[:model_file_id])
    @versions = @model.versions
    @dropbox_revisions = dropbox_client.revisions(@model.path)
    @member = params[:member_id]? Member.find(params[:member_id]) : current_member
    @breadcrumbs = to_breadcrumbs(@model.path, @member)
    @versions = @model.versions
    @dropbox_revisions = dropbox_client.revisions(@model.path)
    @dropbox_revisions = @dropbox_revisions.map do |revision|
      version = Version.find_by_revision_number(revision["rev"])
      { rev: revision["rev"],
        modified: version ? version.revision_date : revision["modified"],
        version: version,
        details: version ? version.details : ""
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: @versions }
      format.html
    end
  end

  def create
    model_file = ModelFile.find(params[:model_file_id])
    revision_date = params[:revision_date]
    version = model_file.versions.build(
      revision_number: params[:revision_number],
      revision_date: revision_date,
      details: params[:details],
    )
    if version.save
      respond_to do |format|
        format.js { render text: version.id }
      end
    end
  end

  def destroy
    Version.find(params[:id]).destroy
    respond_to { |format| format.js }
  end

end
