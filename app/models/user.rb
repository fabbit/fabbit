class User < ActiveRecord::Base
  attr_accessible :dropbox_uid

  validates :dropbox_uid, presence: true

  has_many :discussions, dependent: :destroy
end
