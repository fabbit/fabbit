# == Description
#
# Controller for GroupProject

class GroupProjectsController < ApplicationController

  before_filter :admin_member

  # Add a project to a group
  #
  # == Variables
  #
  # - @group_project: the created group_project
  def create
    group = Group.find(params[:group_id])
    project = Project.find(params[:project_id])
    @group_project = group.projects << project
    respond_to do |format|
      format.js
    end
  end

  # Remove a project from a group
  #
  # == Variables
  #
  # - @removed: the removed group_project
  def destroy
    @removed = GroupProject.find(params[:id]).destroy
    respond_to do |format|
      format.js
    end
  end

end
