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

    if !@discussion.save
      @error = true
    else
      notification = current_member.notification
      notification.count = notification.count + 1
      notification.save
    end

    respond_to do |format|
      format.js do
        if @error
          render text: @discussion.errors.full_messages.join(", "), status: 403
        end
      end
    end
  end

end
