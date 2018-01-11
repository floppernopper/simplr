class Treasure < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :secret
  belongs_to :treasure
  
  has_many :secrets
  has_many :treasures
  has_many :game_pieces
  
  before_create :gen_unique_token, :gen_unique_name, :random_xp, :random_power
  validate :one_discovery, :unique_name, on: :create

  mount_uploader :image, ImageUploader
  
  def self.special_loop
    the_special = :special
  end
  
  def giver
    User.find_by_id(self.giver_id)
  end
  
  def self.random user=nil
    _treasure = nil
    # only gets parent treasures
    _treasures = self.where(treasure_id: nil)
    treasures = []; for treasure in _treasures
      # only gets treasures that haven't been looted yet if user supplied
      unless user and treasure.looted_by? user or treasure.power.eql? 'discover'
        treasures << treasure
      end
    end
    if treasures.present?
      rand_num = rand 0..treasures.size-1
      i=0; for treasure in treasures
        if i.eql? rand_num
          _treasure = treasure
          break
        end
        i+=1
      end
    else
      _treasure = self.create
    end
    return _treasure
  end
  
  def looted_by? user
    true if self.name.present? and user.treasures.find_by_name self.name
  end
  
  def self.powers
    { # Discover: access to hidden treasure system, to xp leveling from treasure or general
      # Discover is never returned as random
      discover: 'Discover secrets',
      hype_others: 'Hype up other users',
      anarchy: 'Make motions or proposals',
      see_views: "See who's viewing posts",
      like_likes: "Like that someone liked something",
      love: 'Love other users posts',
      whoa: 'Say whoa to other users posts',
      zen: 'Say when other users posts are zenful',
      invade_groups: 'Invade private groups',
      create_bots: 'Create bots to perform tasks',
      invite_someone: 'Invite someone to the site',
      steal_powers: 'Steal someone elses power',
      make_follower: 'Make someone your follower',
      steal_followers: 'Steal other peoples followers',
      shutdown: 'Shutdown entire website, alter homepage' }
  end
  
  def self.types
    { portal: 'Portal - leads to another treasure',
      maze: 'Maze - choose between two or more',
      game: 'Game - Play and win to receive a prize',
      prize: 'Prize - rewarded with power or high XP',
      kanye: 'Kanye - nothing but text (dead end)',
      hype: 'Hype - A nugget of pure positivity' }
  end
  
  private
    # unique names but doesn't interfere with looting
    def unique_name
      if self.user_id.nil? and self.name.present?
        _treasure = Treasure.find_by_name self.name
        if _treasure
          errors.add :unique_name, "Name must be unique"
        end
      end
    end
    
    # prevents duplicate discover treasures from being created
    def one_discovery
      if self.user_id and self.power.eql? 'discover'
        user = User.find_by_id(self.user_id)
        if user and user.treasures.find_by_power self.power
          errors.add :one_discovery, "Discover only once"
        end
      end
    end
    
    def random_power
      unless self.power.present?
        powers = Treasure.powers.keys
        # never return discover as random
        powers.delete_if {|p| p.eql? 'discover'}
        i=1; for power in powers
          if rand(0..i).zero?
            self.power = power.to_s
            break
          end
          i+=1
        end
        self.power ||= powers[0].to_s
      end
    end
    
    def random_xp
      if self.xp.nil?
        xp_amounts = Fibonacci.seq 5..17
        i=1; for xp in xp_amounts
          if rand(0..i).zero?
            self.xp = xp
            break
          end
          i+=1
        end
        self.xp ||= xp_amounts[0]
      end
      if self.treasure_type.eql? 'kanye'
        self.xp = -53
      end
    end
    
    # sets a generic placeholder name unless named by user
    def gen_unique_name
      unless self.name.present?
        self.name = "generic_#{SecureRandom.urlsafe_base64}"
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
