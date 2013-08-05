class GroupsController < ApplicationController

  # == Description
  #
  # Shows information on the group, including the projects and member it contains.
  #
  # == Variables
  #
  # - @
  def show
    @group = Group.find(params[:id])
    @projects = @group.projects
    @new_project = Project.new
  end

end
