module NotificationsHelper

  # Get all notifications for the current member
  def get_notifications(page=1, per_page=nil)
    my_annots = current_member.annotations
    tracked_annots = current_member.tracked_annotations

    my_discs = current_member.discussions
    tracked_discs = current_member.tracked_discussions

    proj = ProjectModelFile.all

    notifications = []

    my_annots.each do |item|
      notifications << item.to_notification(current_member)
    end

    tracked_annots.each do |item|
      notifications << item.to_notification(current_member)
    end

    my_discs.each do |item|
      notifications << item.to_notification(current_member)
    end

    tracked_discs.each do |item|
      notifications << item.to_notification(current_member)
    end

    proj.each do |item|
      notifications << item.to_notification(current_member)
    end

    notifications = notifications.sort_by { |item| item[:time] }.reverse

    per_page ||= 8

    head = per_page * (page - 1)
    tail = per_page * page - 1
    notifications[head..tail]
  end

end
