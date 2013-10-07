class MembersController < ApplicationController

  def show

    if current_member.admin?
      if params[:project_id]
        @project = Project.find(params[:project_id])
        @member = Member.find(params[:id])
        @model_files = @member.files_in(@project)

        Breadcrumbs.add title: "Projects", link: navigate_url
        Breadcrumbs.add title: @project.name, link: @project
        Breadcrumbs.add title: @member.name, link: project_member_url(@project, @member)
      end
    else
      redirect_to root_path
    end

  end

  def index
  end

end
