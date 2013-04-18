class DiscussionsController < ApplicationController

  def index
    annotation = Annotation.find(params[:annotation_id])
    @discussions = annotation.discussions
    respond_to do |format|
      format.html { redirect_to ModelFile.find(params[:model_file_id]) }
      format.json { render json: @discussions }
    end
  end

  def create
    user = User.find_by_dropbox_uid(dropbox_client.account_info["uid"].to_s)

    annotation = Annotation.find(params[:annotation_id])
    discussion = annotation.discussions.new(
      text: params[:text],
    )
    discussion.user = user

    if discussion.save
      respond_to do |format|
        format.js { render text: discussion.user_id }
      end
    else
      # error message
    end
  end

end
