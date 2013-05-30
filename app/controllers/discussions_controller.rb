# == Description
# Controller for the Discussion model

class DiscussionsController < ApplicationController

  # List all Discussion objects for a given Annotation
  #
  # === Responses
  # - HTML: Redirects to the corresponding model file
  #   - NOTE: I noted this in AnnotationsController, but I don't think this line is really
  #     necessary, and furthermore in this case I don't think it even works.
  # - JSON: Return a JSON object of all discussions, with access to its member_name method
  def index
    annotation = Annotation.find(params[:annotation_id])
    @discussions = annotation.discussions
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      # TODO: remove and test

      format.json { render json: @discussions.to_json({ methods: :member_name }) }
    end
  end

  # Create a new Discussion for the current Member.
  #
  # === Responses
  # - JS: Return the member's name
  def create
    member = Member.find_by_dropbox_uid(dropbox_client.account_info["uid"].to_s)
    # TODO: write helper for current user

    annotation = Annotation.find(params[:annotation_id])
    discussion = annotation.discussions.new(
      text: params[:text],
    )
    discussion.member = current_member

    if discussion.save
      respond_to do |format|
        format.js { render text: discussion.member_id } # TODO change to member name
      end
    else
      # error message
    end
  end

end
