# == Description
# Controller for the Discussion model

class DiscussionsController < ApplicationController

  # List all Discussion objects for a given Annotation
  #
  # === Variables
  # - @discussions: list of discussions in the annotation
  #
  # === Responses
  #
  # - JSON: Return a JSON object of all discussions, with access to its member_name method
  def index
    annotation = Annotation.find(params[:annotation_id])
    @discussions = annotation.discussions
    respond_to do |format|
      format.json { render json: @discussions.to_json({ methods: :member_name }) }
    end
  end

  # Create a new Discussion for the current Member.
  #
  # === Variables
  # - @discussion = the newly created discussion
  #
  # === Responses
  # - JS: Return the member's name
  def create
    annotation = Annotation.find(params[:annotation_id])
    @discussion = annotation.discussions.new(
      text: params[:text],
    )
    @discussion.member = current_member

    if @discussion.save
      respond_to do |format|
        format.js { render text: @discussion.member_id } # just format.js if using callback
      end
    else
      # error message
      # most likely the message was blank, so show a warning
    end
  end

end
