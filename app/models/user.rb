class User < ActiveRecord::Base
  attr_accessible :dropbox_uid

  validates :dropbox_uid, presence: true

  has_many :discussions, dependent: :destroy

  def dropbox_client=(dropbox_client)
    @dropbox_client = dropbox_client
  end

  def dropbox_client
    @dropbox_client
  end

  def name
    @dropbox_client.account_info["display_name"]
  end

end
