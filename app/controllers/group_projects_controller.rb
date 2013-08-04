class GroupProjectsController < ApplicationController

  def create
    group = Group.find(params[:group_id])
    project = Project.find(params[:project_id])
    @group_project = group.projects << project
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @removed = GroupProject.find(params[:id]).destroy
    respond_to do |format|
      format.js
    end
  end

end
