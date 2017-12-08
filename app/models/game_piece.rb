class GamePiece < ActiveRecord::Base
  belongs_to :game_piece
  belongs_to :treasure
  belongs_to :secret
  belongs_to :user
  belongs_to :game
  
  has_many :game_pieces
  
  before_create :gen_unique_token

  mount_uploader :image, ImageUploader
  
  def dead?
    if self.health and health <= 0.0
      true
    end
  end
  
  def attack target
    # check targets class relation to self class
    # check if any armor, what type of armor
    
    # subtract stamina or mana from self
    
    # subtract health or stamina from target
    
    # rolls dice for damage
    range = case self.game_class.to_sym
    when :warrior, :mage, :rogue, :paladin
      2..9
    when :ranger, :warlock
      1..7
    else # priest
      0..6
    end
    nums = fib_seq range
    damage = nums[rand(nums.size)]
    target.update health: target.health - damage
    return damage
  end
  
  def self.classes
    _classes = {
      # main classes of combat triangle
      warrior: { name: "Chad Warrior", health: 12, melee: [:hack, :slash, :stab] },
      ranger: { name: "Virgin Ranger", health: 11, melee: [:slash], ranged: [:bow_single_shot] },
      mage: { name: "Vaporwave Mage", health: 10, melee: [:bludgeon], magic: [:fire, :frost, :shock, :invisibility] },
      
      # Additional classes
      priest: { name: "Wholesome Healer", health: 10, melee: [:bludgeon], magic: [:fast_heal, :protect_other] },
      rogue: { name: "Dat Boi Rogue", health: 11, melee: [:stab, :slash], special: [:sneak] },
      warlock: { name: "Social Justice Warlock", health: 11, melee: [:stab], magic: [:conjure, :drain] },
      paladin: { name: "Antifa Super-soldier", health: 12, melee: [:stab, :slash, :bludgeon], magic: [:area_heal] }
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

# oprah The Secret
  # warlock

# press F
  # all

# GTA wasted
  # all
  
# confused mr krabs
  # all
