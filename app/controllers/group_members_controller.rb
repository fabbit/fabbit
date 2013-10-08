# == Description
#
# Controller for GroupMember. Handles adding and removing members from a Group.
class GroupMembersController < ApplicationController

  # Join a Group
  #
  # == Variables
  #
  # - @group_member: created group_member
  def create
    group = Group.find(params[:group_id])
    member = current_member
    @group_member = group.members << current_member
    respond_to do |format|
      format.js
    end
  end

  # Leave a group
  def destroy
    @removed = GroupMember.find(params[:id]).destroy
    respond_to do |format|
      format.js
    end
  end

end
