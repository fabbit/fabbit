class NotificationsController < ApplicationController

  def index
    items = 20

    @notifications = get_notifications(page = 1, per_page = 30)
  end

  def update
    notification = Notification.find(params[:id])
    notification.count -= params[:count]
    notification.save

    respond_to do |format|
      format.js
    end
  end
end
