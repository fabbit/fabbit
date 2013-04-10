class Discussion < ActiveRecord::Base
  attr_accessible :annotation_id, :text, :uid

  validates :uid, :text, :annotation_id, presence: true
end
