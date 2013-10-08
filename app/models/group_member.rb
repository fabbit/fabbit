# == Schema Information
#
# Table name: group_members
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  member_id  :integer
#  admin      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# Many-to-many relationship class between the Group and Member models.
# Also contains the flag for admin members.
#
# == Associations
#
# Belongs to:
# - Member
# - Group

class GroupMember < ActiveRecord::Base
  belongs_to :member
  belongs_to :group
end
