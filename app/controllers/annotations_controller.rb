# == Description
#
# Controller for the Annotation model.

class AnnotationsController < ApplicationController

  # Loads all annotations for a given Version of a ModelFile.
  # Currently also allows calls without a version, which will load the most recent version of the
  # model file.
  #
  # === Responses
  # - HTML: Redirect to the corresponding model file page
  #   - NOTE: I have no idea why I'm doing this at the moment
  # - JSON: Return a JSON object of all annotations, including all of the Discussions for each
  #   annotation
  def index
    model_file = ModelFile.find(params[:model_file_id])

    # handle version if given a version ID, else use the most recent
    # TODO: shold be using model_file.latest_version, but need to test first
    version = params[:version_id] ? Version.find(params[:version_id]) : model_file.versions.first
    @annotations = version.annotations
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      format.json do
        render json: @annotations.to_json(include: { discussions: { methods: :member_name } })
      end
    end
  end

  # Create a new annotation based on what is created on the 3D viewer.
  #
  # === Responses
  # - JS: Return the ID of the new annotation
  def create
    member = Member.find_by_dropbox_uid(dropbox_client.account_info["uid"].to_s)

    model_file = ModelFile.find(params[:model_file_id])

    # TODO: use the one line for this
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
