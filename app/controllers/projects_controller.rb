class ProjectsController < ApplicationController

  before_filter :live_dropbox_session

  def show
  end

  def index
    if params[:member_id]
      @projects = Member.find(params[:member_id]).projects
    elsif current_user?
      @projects = current_user.projects
    else
      @projects = Project.all
    end
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
