# Meme war attaccs #

# confused mr krabs
# doge attacc
  # warrior, ranger
  
# edge cast or slice
  # warrior, mage, rogue, paladin
  
# hax.exe 127.0.0.1
  # mage, warlock, paladin
  
# jazz cast
  # mage, warlock
  
# TR-8R attacc
  # warrior, paladin
  
# unnecessary explosions
  # mage, warlock
  
# greek riot dog attacc
  # paladin


# Meme war events/player reaccs/actions #

# doge protecc
  # warrior, ranger

# homer bush hide
  # rogue, ranger
  
# greek riot dog protecc
  # paladin
  
# wall of text
  # warlock

# press F
  # all

# GTA wasted
  # all
  
# confused mr krabs
  # all
  
class GamePiece < ActiveRecord::Base
  belongs_to :game_piece
  belongs_to :treasure
  belongs_to :secret
  belongs_to :user
  belongs_to :game
  
  has_many :game_pieces
  
  before_create :gen_unique_token

  mount_uploader :image, ImageUploader
  
  def self.classes
    _classes = {
      warrior: "Chad Warrior",
      ranger: "Virgin Ranger",
      mage: "Vaporwave Mage",
      priest: "Wholesome Healer",
      rogue: "Dat Boi Rogue",
      warlock: "Social Justice Warlock",
      paladin: "Antifa Super-soldier"
    }
    return _classes
  end
  
  private
  
  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while GamePiece.exists? unique_token: self.unique_token
  end
end
