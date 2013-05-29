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
#  user_id     :integer
#

require 'spec_helper'

describe Annotation do
  pending "add some examples to (or delete) #{__FILE__}"
end
