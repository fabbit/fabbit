class ProjectModelFilesController < ApplicationController

  before_filter :live_dropbox_session

  # Add a ModelFile to a Project.
  def create
    project = Project.find(params[:project_id])
    model_file = ModelFile.find(params[:model_file_id])
    @successful = false

    if project.model_files << model_file
      @successful = true
    end

    respond_to do |format|
      format.js
    end
  end

  # Delete a ModelFile from a Project
  def destroy
    @project_model_file = ProjectModelFile.find(params[:id])
    if @project_model_file.destroy
      respond_to do |format|
        format.js { render json: @project_model_file }
      end
    end
  end

end
