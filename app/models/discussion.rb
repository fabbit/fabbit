# == Schema Information
#
# Table name: discussions
#
#  id            :integer          not null, primary key
#  annotation_id :integer
#  member_id     :string(255)
#  text          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# == Description
#
# A piece of discussion about an Annotation, created by a Member.
# *NOTE:* May be changed to a discussion thread
#
# == Attributes
#
# [+text+] The content of the discussion
#
# == Associations
#
# Belongs to:
# - Member
# - Annotation

class Discussion < ActiveRecord::Base
  attr_accessible :text

  validates :member_id, :text, :annotation_id, presence: true

  belongs_to :member
  belongs_to :annotation

  default_scope order('created_at ASC')
  # Shortcut for getting a member's name
  def member_name
    self.member.name
  end

  # Generate a message and a link for notifications
  def to_notification(current_member)
    member_name = self.member == current_member ? "You" : "#{self.member.name}"
    owner_name = self.annotation.version.member == current_member ? "your" : "#{self.annotation.version.member.name}'s"
    file_name = self.annotation.version.name
    {
      message: "#{member_name} added to a discussion on #{owner_name} file #{file_name}",
      link: "/versions/#{self.annotation.version.id}",
      time: self.created_at,
    }
  end
end
