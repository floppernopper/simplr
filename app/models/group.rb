class Group < ActiveRecord::Base
  belongs_to :user
  has_many :posts, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  mount_uploader :image, ImageUploader
  
  def invite_to_join _user
    self.connections.create _user.id, invite: true
  end
  
  def remove _user
    connection = self.connections.find_by_user_id _user.id
    connection.destroy if connection
  end
  
  def members
    _members = []
    self.connections.current.each do |connection|
      _members << connection.user if connection.user
    end
    return _members
  end
  
  def invites
    self.connections.invites
  end
  
  def requests
    self.connections.requests
  end
end
