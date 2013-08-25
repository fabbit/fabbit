class NotificationsController < ApplicationController

  def index
    items = 20

    my_annots = current_member.annotations
    tracked_annots = current_member.tracked_annotations

    my_discs = current_member.discussions
    tracked_discs = current_member.tracked_discussions

    proj = ProjectModelFile.all

    @notifications = []

    my_annots.each do |item|
      @notifications << item.to_notification(current_member)
    end

    tracked_annots.each do |item|
      @notifications << item.to_notification(current_member)
    end

    my_discs.each do |item|
      @notifications << item.to_notification(current_member)
    end

    tracked_discs.each do |item|
      @notifications << item.to_notification(current_member)
    end

    proj.each do |item|
      @notifications << item.to_notification(current_member)
    end

    @notifications = @notifications.sort_by { |item| item[:time] }.reverse
  end
end
