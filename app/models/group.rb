# == Schema Information
#
# Table name: groups
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  group_type_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# == Description
#
# A group of members that collaborate on Fabbit. Members that are part of a group has access to
# projects that are part of the group.
#
# == Attributes
#
# [+name+] The name of the group
#
# == Associations
#
# Has many:
# - Member
#

class Group < ActiveRecord::Base
  attr_accessible :name

  validates :name, presence: true

  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members

  has_many :group_projects, dependent: :destroy
  has_many :projects, through: :group_projects
end
