# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  count      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# == Description
#
# Model for storing notification information
#
# == Attributes
#
# [+count] Used to track how many notifications the Member has
#
# == Associations
#
# Belongs to:
# - Member
class Notification < ActiveRecord::Base
  attr_accessible :count, :member_id

  belongs_to :member

  before_save { self.count = 0 if self.count < 0 }

end
