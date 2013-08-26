module NotificationsHelper

  # Get all notifications for the current member
  def get_notifications(page=1, per_page=nil, show_unread=true)
    my_annots = current_member.annotations
    tracked_annots = current_member.tracked_annotations

    annots = (my_annots + tracked_annots).uniq

    my_discs = current_member.discussions
    tracked_discs = current_member.tracked_discussions

    discs = (my_discs + tracked_discs).uniq

    proj = ProjectModelFile.all

    notifications = []

    annots.each do |item|
      notifications << item.to_notification(current_member)
    end

    discs.each do |item|
      notifications << item.to_notification(current_member)
    end

    proj.each do |item|
      notifications << item.to_notification(current_member)
    end

    notifications = notifications.sort_by { |item| item[:time] }.reverse

    if not show_unread
      notifications = notifications[0..(current_member.notification.count - 1)]
      notifications = [] if current_member.notification.count == 0
    end

    per_page ||= 8

    head = per_page * (page - 1)
    tail = per_page * page - 1
    notifications[head..tail]
  end

end
