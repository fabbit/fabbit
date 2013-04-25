class Discussion < ActiveRecord::Base
  attr_accessible :text

  validates :member_id, :text, :annotation_id, presence: true

  belongs_to :member

  def member_name
    self.member.name
  end
end
