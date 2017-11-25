class Game < ApplicationRecord
  belongs_to :user
  
  has_many :connections, dependent: :destroy
  has_many :game_pieces, dependent: :destroy
  
  def self.class_selected_yet? user
    if user.meme_war_class.present?
      return true
    end
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
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while Game.exists? unique_token: self.unique_token
  end
end
