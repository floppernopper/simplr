class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  validate :unique_to_user, on: :create
  
  scope :invites, -> { where invite: true }
  scope :requests, -> { where request: true }
  scope :current, -> { where.not(invite: true).where.not request: true }
  
  private
    
  def unique_to_user
    connections = User.find_by_id(self.user_id).connections
    if connections.find_by_other_user_id self.other_user_id or connections.find_by_group_id self.group_id
      errors.add(:connection, "already exists.")
    end
  end
end
