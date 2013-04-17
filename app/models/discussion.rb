class Discussion < ActiveRecord::Base
  attr_accessible :annotation_id, :text

  validates :user_id, :text, :annotation_id, presence: true

  belongs_to :user
end
