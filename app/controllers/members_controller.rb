# == Description
#
# Controller for Member

class MembersController < ApplicationController

  # Display information about the member. The information displayed will be different depending on
  # what URL it is nested under.
  #
  # === Project
  #
  # Shows the files that the member has in the project.
  #
  # ==== Variables
  # - @project: the project
  # - @member: the member
  # - @model_files: the files the member has under the project
  def show

    if current_member.admin?
      if params[:project_id]
        @project = Project.find(params[:project_id])
        @member = Member.find(params[:id])
        @model_files = @member.files_in(@project)

        # Generate breadcrumbs
        Breadcrumbs.add title: "Projects", link: navigate_url
        Breadcrumbs.add title: @project.name, link: @project
        Breadcrumbs.add title: @member.name, link: project_member_url(@project, @member)
      end
    else
      redirect_to root_path
    end

  end

end
