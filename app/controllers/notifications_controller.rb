class NotificationsController < ApplicationController

  def index
    items = 20

    @notifications = current_member.notifications(page = 1, per_page = 30)
  end

  def update
    notification = Notification.find(params[:id])
    notification.count -= params[:count].to_i
    notification.save

    respond_to do |format|
      format.js
    end
  end
end
