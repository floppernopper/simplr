class Game < ApplicationRecord
  belongs_to :user
  
  has_many :connections, dependent: :destroy
  has_many :game_pieces, dependent: :destroy
  
  before_create :gen_unique_token
  
  def your_turn? user
    player = self.connections.find_by_id self.current_turn_of_id
    if player and player.user and player.user.eql? user
      player
    else
      nil
    end
  end
  
  def self.class_selected_yet? user
    if Game.meme_war_class user
      return true
    end
  end
  
  def self.meme_war_class user
    whats_there = user.game_pieces.where.not meme_war_class: nil
    _class = if whats_there.present?
      whats_there.last.meme_war_class
    end
    _class
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
