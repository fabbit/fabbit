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
    annotation = Annotation.find(params[:annotation_id])
    discussion = annotation.discussions.new(
      uid: params[:uid],
      text: params[:text],
    )

    if discussion.save
      respond_to do |format|
        format.js { render text: discussion.uid }
      end
    else
      # error message
    end
  end

end
