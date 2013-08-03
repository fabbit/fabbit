# == Schema Information
#
# Table name: members
#
#  id          :integer          not null, primary key
#  dropbox_uid :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string(255)
#

# == Description
#
# A member of Fabbit, corresponding to a Dropbox user.
#
# == Attributes
#
# [+dropbox_uid+] The user ID given by Dropbox
# [+name+] The user's name as given by Dropbox
#
# == Associations
#
# Has many:
# - Discussion
# - ModelFile
# - Group

class Member < ActiveRecord::Base
  attr_accessible :dropbox_uid, :name

  validates :dropbox_uid, :name, presence: true

  has_many :discussions, dependent: :destroy
  has_many :model_files, dependent: :destroy

  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members

  def projects
    self.model_files.map { |model_file| model_file.projects }.flatten.compact.uniq
  end
end
