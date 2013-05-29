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

require 'spec_helper'

describe Discussion do
  pending "add some examples to (or delete) #{__FILE__}"
end
