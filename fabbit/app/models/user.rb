class User < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :password
  has_secure_password

  validates :email, :first_name, :last_name, :password, :password_confirmation, presence: true
  validates :password, confirmation: true

  def full_name
    [ self.first_name, self.last_name ].join(" ")
  end
end
