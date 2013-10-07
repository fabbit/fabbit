class ProjectModelFilesController < ApplicationController

  before_filter :live_dropbox_session

  # Add a ModelFile to a Project.
  def create
    @project = Project.find(params[:project_id])
    model_file = ModelFile.find(params[:model_file_id])
    @project_model_file = @project.project_model_files.build(model_file_id: model_file.id)
    @successful = false

    if @project_model_file.save
      @successful = true
      current_member.notification.count += 1
      current_member.notification.save
    end

    respond_to do |format|
      format.js
    end
  end

  # Delete a ModelFile from a Project
  def destroy
    @project_model_file = ProjectModelFile.find(params[:id])
    @project = @project_model_file.project
    if @project_model_file.destroy
      respond_to do |format|
        format.js
      end
    end
  end

  # Add multiple files to a project.
  def add_all
    project = Project.find(params[:project_id])

    project.model_files.destroy_all

    if params[:paths]
      params[:paths].each do |path|
        model_file = find_or_initialize(path)

        project.model_files << model_file

        current_member.notification.count += 1
        current_member.notification.save
      end
    end

    respond_to do |format|
      format.js
    end
  end

end
