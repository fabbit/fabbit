# == Description
#
# Controller for Project

class ProjectsController < ApplicationController

  before_filter :admin_member, only: :create

  # Display information about the project, including its members and model_files
  #
  # == Variables
  # - @project: the project
  # - @model_files: model files in the project
  # - @show_manage_project: toggle for the manage files button
  def show
    @project = Project.find(params[:id])
    @model_files = current_member.admin? ? @project.model_files : current_member.files_in(@project)

    @show_manage_project = true

    make_project_breadcrumbs(@project)
  end

  # Show all projects in a Group.
  #
  # == Variables
  # - @group: the group
  # - @projects: all projects in the group
  def index
    @group = Group.find(params[:id]) if params[:id]
    @projects = @group.projects

    make_project_breadcrumbs
  end

  # Create a new project
  #
  # == Variables
  # - @project: the new project
  def create
    @project = Project.new(params[:project])

    @project.save

    respond_to do |format|
      format.js   # create.js.erb
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
