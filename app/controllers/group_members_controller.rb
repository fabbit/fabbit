class GroupMembersController < ApplicationController

  def create
    group = Group.find(params[:group_id])
    member = current_member
    @group_member = group.members << current_member
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @removed = GroupMember.find(params[:id]).destroy
    respond_to do |format|
      format.js
    end
  end

end
