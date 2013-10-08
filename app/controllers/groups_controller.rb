class GroupsController < ApplicationController

  # == Description
  #
  # Shows information on the group, including the projects and member it contains.
  #
  # == Variables
  #
  # - @group: the group
  # - @projects: projects that belong to the group
  # - @new_project: for creating a new project
  def show
    @group = Group.find(params[:id])
    @projects = @group.projects
    @new_project = Project.new
  end

end
