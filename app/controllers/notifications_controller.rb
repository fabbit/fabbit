class NotificationsController < ApplicationController

  def index
    items = 20

    @notifications = get_all_notifications
  end
end
