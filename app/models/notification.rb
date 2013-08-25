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
end
