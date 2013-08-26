class NotificationsController < ApplicationController

  def index
    items = 20

    @notifications = get_notifications(page = 1, per_page = 30)
  end
end
