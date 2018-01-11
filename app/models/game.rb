class Game < ApplicationRecord
  belongs_to :user
  
  has_many :connections, dependent: :destroy
  has_many :game_pieces, dependent: :destroy
  
  before_create :gen_unique_token
  
  def self.between? user, other_user
    user_c = Connection.where.not(game_id: nil).where user_id: user.id
    other_user_c = Connection.where.not(game_id: nil).where user_id: other_user.id
    
    for x in [[user_c, other_user_c], [other_user_c, user_c]]
      for c in x[0]
        return true if x[1].any? { |i| i.game_id.eql? c.game_id }
      end
    end
    nil
  end
  
  def self.my_games user  
    games = []
    Connection.where.not(game_id: nil).where(user_id: user.id).each do |c|
      games << Game.find(c.game_id)
    end
    games
  end
  
  def all_players_ready?
    self.players.all? { |p| p._class }
  end
  
  def your_turn? user
    player = self.connections.find_by_id self.current_turn_of_id
    if player and player.user and player.user.eql? user
      player
    else
      nil
    end
  end
  
  def self.class_selected_yet? user
    if Game._class user
      return true
    end
  end
  
  def self._class user
    whats_there = user.game_pieces.where.not game_class: nil
    _class = if whats_there.present?
      whats_there.last.game_class
    end
    _class
  end
  
  def other_players user
    return players.delete_if { |p| p.eql? user }
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
