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

require 'spec_helper'

describe Notification do
  pending "add some examples to (or delete) #{__FILE__}"
end
