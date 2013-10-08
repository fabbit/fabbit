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

require 'spec_helper'

describe GroupMember do
  pending "add some examples to (or delete) #{__FILE__}"
end
