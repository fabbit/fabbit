class MembersController < ApplicationController

  def show

    if params[:project_id]
      @project = Project.find(params[:project_id])
      @member = Member.find(params[:id])
      @model_files = @member.files_in(@project)

      Breadcrumbs.add title: "Projects", link: navigate_url
      Breadcrumbs.add title: @project.name, link: @project
      Breadcrumbs.add title: @member.name, link: project_member_url(@project, @member)
    end

  end

  def index
  end

end
