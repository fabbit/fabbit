class ProjectsController < ApplicationController

  before_filter :live_dropbox_session

  def show
    @project = Project.find(params[:id])
    @model_files = @project.model_files
  end

  def index
    @group = Group.find(params[:id]) if params[:id]
    @projects = Project.all
  end

  def new
    @new_project = current_user.projects.new
  end

  def create
    project = Project.new(params[:new_project])

    respond_to do |format|
      format.js
    end
  end

end
