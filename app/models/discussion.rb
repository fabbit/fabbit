class Discussion < ActiveRecord::Base
  attr_accessible :text

  validates :user_id, :text, :annotation_id, presence: true

  belongs_to :user

  def user_name
    p "test"
    self.user.name
  end
end
