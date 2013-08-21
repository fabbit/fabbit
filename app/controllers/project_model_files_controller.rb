class ProjectModelFilesController < ApplicationController

  before_filter :live_dropbox_session

  # Add a ModelFile to a Project.
  def create
    project = Project.find(params[:project_id])
    model_file = ModelFile.find(params[:model_file_id])
    @project_model_file = project.project_model_files.build(model_file_id: model_file.id)
    @successful = false

    if @project_model_file.save
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
        format.js
      end
    end
  end

end
