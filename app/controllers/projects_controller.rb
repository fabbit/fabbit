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

    if project.save
      flash[:success] = "Successfully created #{project.name}"
      redirect_to project.members
    else
      flash.now["error"] = "Sorry, there was a problem with the new project."
      render "new"
    end
  end

end
