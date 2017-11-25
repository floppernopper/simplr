class Game < ApplicationRecord
  belongs_to :user
  
  has_many :connections, dependent: :destroy
  has_many :game_pieces, dependent: :destroy
  
  def class_selected_yet? user
    true
  end
  
  def players
    _players = []
    for c in self.connections
      user = User.find_by_id c.user_id
      _players << user if user
    end
    return _players
  end
  
  private
  
  def gen_unique_token
    self.unique_token = SecureRandom.urlsafe_base64
  end
end
