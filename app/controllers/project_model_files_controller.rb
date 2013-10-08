# == Description
#
# Controller for adding model files to projects
class ProjectModelFilesController < ApplicationController

  skip_before_filter :load_notifications, :clear_breadcrumbs

  # Add a ModelFile to a Project.
  #
  # == Variables
  # - @project: the project being added to
  # - @project_model_file: the created ProjectModelFile
  # - @successful: true if adding the model file to the project was successful
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
      format.js   # create.js.erb
    end
  end

  # Delete a ModelFile from a Project
  #
  # == Variables
  # - @project_model_file: the deleted ProjectModelFile
  # - @project: the project that lost a model file
  def destroy
    @project_model_file = ProjectModelFile.find(params[:id])
    @project = @project_model_file.project
    if @project_model_file.destroy
      respond_to do |format|
        format.js   # destroy.js.erb
      end
    end
  end

  # Add multiple files to a project
  def add_all
    project = Project.find(params[:project_id])

    # Remove all files belonging to the current_member in the project
    project.model_files.destroy(current_member.files_in(project))

    if params[:paths]
      params[:paths].each do |path|

        # Initialize files if not initialized
        model_file = find_or_initialize(path)

        # Add file to project
        project.model_files << model_file

        # Update notifications
        current_member.notification.count += 1
        current_member.notification.save
      end
    end

    respond_to do |format|
      format.js   # add_all.js.erb
    end
  end

end
