class ProjectsController < ApplicationController

  after_filter :make_project_breadcrumbs

  def show
    @project = Project.find(params[:id])
    @model_files = current_member.admin? ? @project.model_files : current_member.files_in(@project)

    @show_manage_project = true

    make_project_breadcrumbs(@project)
  end

  def index
    @group = Group.find(params[:id]) if params[:id]
    @projects = Project.all

    make_project_breadcrumbs
  end

  def new
    @new_project = current_user.projects.new
  end

  def create
    @project = Project.new(params[:project])

    @project.save

    respond_to do |format|
      format.js
    end
  end

  private

    # Generate project breadcrumbs
    def make_project_breadcrumbs(project=nil)
      Breadcrumbs.add title: "Projects", link: navigate_url

      if project
        Breadcrumbs.add project
      end
    end

  # end private


end
