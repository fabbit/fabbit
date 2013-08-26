# == Description
#
# Controller for the Annotation model.

class AnnotationsController < ApplicationController

  # Loads all annotations for a given Version of a ModelFile.
  # Currently also allows calls without a version, which will load the most recent version of the
  # model file.
  #
  # *NOTE*: doesn't work (will fix if put in use)
  #
  # === Variables
  # - @annotations: list of annotations for the version of the model file
  #
  # === Responses
  # - HTML: Redirect to the corresponding model file page
  #   - NOTE: I have no idea why I'm doing this at the moment
  # - JSON: Return a JSON object of all annotations, including all of the Discussions for each
  #   annotation
  def index
    model_file = ModelFile.find(params[:model_file_id]) if params[:model_file_id]
    version = model_file ? model_file.latest_or_version(params[:version_id]) : Version.find(params[:version_id])
    version = Version.find(params[:version_id])
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
  # === Variables
  # - @annotation = the newly created annotation
  #
  # === Responses
  # - JS: Return the ID of the new annotation
  def create
    model_file = ModelFile.find(params[:model_file_id]) if params[:model_file_id]
    version = model_file ? model_file.latest_or_version(params[:version_id]) : Version.find(params[:version_id])
    @annotation = version.annotations.build(
      coordinates: params[:coordinates],
      camera: params[:camera],
      text: params[:text],
    )

    @annotation.member = current_member
    if not @annotation.save
      @error = true
      current_member.notifications.count += 1
    end

    respond_to do |format|
      format.js do
        if @error
          render text: @annotation.errors.full_messages.join(", "), status: 403
        else
          render text: @annotation.id # just format.js if using callback
        end
      end
    end
  end

end
