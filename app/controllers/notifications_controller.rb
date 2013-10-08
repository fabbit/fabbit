# == Description
#
# Controller for Notification
class NotificationsController < ApplicationController

  # Show all notifications for the current_member
  #
  # == Variables
  # - @notifications: a set of notifications
  def index
    items = 20

    @notifications = current_member.notifications(page: 1, per_page: 30, show_unread: true)
    current_member.notification.count -= 30
    current_member.notification.save
  end

  # Update the notification count.
  def update
    notification = Notification.find(params[:id])
    notification.count -= params[:count].to_i
    notification.save

    respond_to do |format|
      format.js   # update.js.erb
    end
  end
end
