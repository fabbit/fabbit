# == Schema Information
#
# Table name: annotations
#
#  id          :integer          not null, primary key
#  version_id  :integer
#  coordinates :string(255)
#  camera      :string(255)
#  text        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  member_id   :integer
#

# == Description
#
# An annotation on a ModelFile created by a Member.
#
# == Attributes
#
# [+camera+] The camera location when the annotation was created
# [+coordinates+] The specific coordinates of the annotation
# [+text+] A description of the annotation (may be obsolete with the addition of discussions)
#
# == Associations
#
# Has many:
# - Discussion
#
# Belongs to:
# - Version
# - Member

class Annotation < ActiveRecord::Base
  attr_accessible :camera, :coordinates, :text

  validates :version_id, :member_id, :camera, :coordinates, presence: true

  belongs_to :version
  belongs_to :member
  has_many :discussions, dependent: :destroy

  # Generate a message and a link for notifications
  def to_notification(current_member)
    member_name = self.member == current_member ? "You" : "#{self.member.name}"
    owner_name = self.version.member == current_member ? "your" : "#{self.version.member.name}'s"
    file_name = self.version.name
    {
      message: "#{member_name} added an annotation to #{owner_name} file #{file_name}",
      link: "/versions/#{self.version.id}",
      time: self.created_at,
    }
  end
end
