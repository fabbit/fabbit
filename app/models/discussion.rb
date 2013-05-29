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

  # Shortcut for getting a member's name
  def member_name
    self.member.name
  end
end
