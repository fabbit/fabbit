# == Schema Information
#
# Table name: members
#
#  id          :integer          not null, primary key
#  dropbox_uid :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#

# == Description
#
# A member of Fabbit, corresponding to a Dropbox user.
#
# == Attributes
#
# [+dropbox_uid+] The user ID given by Dropbox
# [+name+] The user's name as given by Dropbox
#
# == Associations
#
# Has many:
# - Discussion
# - ModelFile
# - Group

class Member < ActiveRecord::Base
  attr_accessible :dropbox_uid, :name

  validates :dropbox_uid, :name, presence: true

  has_many :discussions, dependent: :destroy
  has_many :annotations, dependent: :destroy

  has_many :model_files, dependent: :destroy
  has_many :versions, through: :model_files
  has_many :tracked_annotations, through: :versions, source: :annotations
  has_many :tracked_discussions, through: :annotations, source: :discussions

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members

  # Repeated Group to Project associations for the projects shortcut methods
  has_many :group_projects, through: :groups
  has_many :projects, through: :group_projects

  has_one :notification, dependent: :destroy

  after_create :add_to_default_group
  after_create :add_notifications

  # Projects that the member have submitted files to
  def participating_projects
    self.model_files.map { |model_file| model_file.projects }.flatten.compact.uniq
  end

  # Retrieves all model files in a certain model file
  def files_in(project)
    project.model_files.where(member_id: self.id)
  end

  # Checks ownership of a ModelFile
  def owns?(model_file)
    model_file.member == self
  end

  # Checks if the current member is an admin of the group. If no group is given, checks the default
  # group.
  def admin?(group=Group.first)
    self.group_members.where(group_id: group.id).first.admin
  end

  # Make the member an admin of the group.
  def make_admin_of(group)
    if self.groups.include?(group)
      gm = self.group_members.where(group_id: group.id).first
      gm.admin = true
      gm.save
    end
  end

  # Remove the admin rights of the member.
  def remove_from_admin(group)
    if self.groups.include?(group)
      gm = self.group_members.where(group_id: group.id).first
      gm.admin = false
      gm.save
    end
  end

  # Get all notifications.
  #
  # Options:
  # - page: The page to show. Used for pagination.
  # - per_page: Number of notifications to show. Defaults to 8.
  # - show_unread: Display unread notifications. Defaults to false.
  def notifications(options={})
    my_annots = self.annotations
    tracked_annots = self.tracked_annotations

    annots = (my_annots + tracked_annots).uniq

    my_discs = self.discussions
    tracked_discs = self.tracked_discussions

    discs = (my_discs + tracked_discs).uniq

    proj = ProjectModelFile.all

    if !self.admin?
      proj = self.projects.map do |project|
        project.project_model_files
      end.flatten.compact.uniq
    end

    notifications = []

    annots.each do |item|
      notifications << item.to_notification(self)
    end

    discs.each do |item|
      notifications << item.to_notification(self)
    end

    proj.each do |item|
      notifications << item.to_notification(self)
    end

    notifications = notifications.sort_by { |item| item[:time] }.reverse

    if not options[:show_unread]
      notifications = notifications[0..(self.notification.count - 1)]
      notifications = [] if self.notification.count == 0
    end

    per_page = options[:per_page] || 8
    page = options[:page] || 1

    head = per_page * (page - 1)
    tail = per_page * page - 1
    notifications[head..tail]
  end


  private

    # Every member should be part of the default group.
    def add_to_default_group
      group = Group.where(name: "Default").first_or_create!
      group.members << self
    end

    # Initialize the member's notifications
    def add_notifications
      Notification.where(member_id: self.id).first_or_create!
    end
end
