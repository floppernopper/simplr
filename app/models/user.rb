class User < ActiveRecord::Base
  has_many :connections, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :treasures
  has_many :groups
  has_many :views

  validates_presence_of :name, length: { minimum: 3 }
  validates_presence_of :password, length: { minimum: 4 }
  validates_uniqueness_of :name
  validates_confirmation_of :password

  before_create :encrypt_password, :generate_token, :gen_unique_token
  after_create :initialize_settings

  mount_uploader :image, ImageUploader
  
  # optional arg to check if power present AND not expired
  def has_power? power, not_expired=nil
    treasure = self.treasures.find_by_power power
    if treasure and not_expired
      return !treasure.expired
    else
      return treasure
    end
  end
  
  def active_powers
    powers = []
    self.treasures.where.not(power: nil).where(expired: [nil, false]).each do |power|
      powers << power unless powers.any? { |_power| power.power.eql? _power.power }
    end
    return powers
  end
  
  def loot treasure
    # duplicates treasure and assigns duplicate to user
    dup_treasure = treasure.dup; dup_treasure.user_id = self.id
    # assigns looted treasure as parent of duplicate
    dup_treasure.treasure_id = treasure.id
    if dup_treasure.save
      # redeems any xp to user from treasure looted
      self.update xp: (self.xp.to_i + treasure.xp.to_i)
      # returns xp to show in view
      return dup_treasure
    end
  end
  
  def level
    xp_to_nxt_lvl = 0; progress = 0.0; lvl = 0
    # leveling scales based on fibonacci, initialized with 0
    fib_nums = [0]; Fibonacci.seq(10..25).each { |n| fib_nums << n }
    (0..fib_nums.size-1).each do |n|
      # if next number in sequence actually present
      if fib_nums[n+1].present?
        # if current XP is between current and next sequence number
        if (fib_nums[n]..fib_nums[n+1]-1).include? self.xp.to_i
          # gets XP left until next level is reached
          xp_to_nxt_lvl = (fib_nums[n+1]-1) - self.xp.to_i
          # gets progress to next level as float (formatted as percentage) for progress bar
          progress = (self.xp.to_i - fib_nums[n]).to_f / ((fib_nums[n+1]-1) - fib_nums[n]).to_f
          # gets current level and breaks out of loop
          lvl = n; break
        end
      end
    end
    # returns current level, current progress, or XP left until next level
    return { xp_left: xp_to_nxt_lvl, progress: progress, lvl: lvl }
  end
  
  def feed
    _feed = []
    for user in following
      user.posts.each { |post| _feed << post }
    end
    for group in my_groups
      group.posts.each do |post|
        _feed << post unless _feed.include? post
      end
    end
    self.posts.each do |post|
      _feed << post unless _feed.include? post
    end
    _feed.sort_by! { |item| item.created_at }
    return _feed.reverse
  end

  def following? other_user
    self.connections.where(other_user_id: other_user.id).present?
  end

  def follow other_user
    self.connections.create other_user_id: other_user.id
  end

  def unfollow other_user
    connection = self.connections.find_by_other_user_id(other_user.id)
    connection.destroy if connection
  end

  def following
    _following = []
    self.connections.each do |connection|
      user = User.find_by_id(connection.other_user_id)
      _following << user if user
    end
    return _following
  end

  def followers
    _followers = []
    Connection.where(other_user_id: self.id).each do |connection|
      _followers << connection.user if connection.user
    end
    return _followers
  end

  def request_to_join group
    self.connections.create group_id: group.id, request: true
  end
  
  def my_groups
    _my_groups = []
    self.groups.each { |group| _my_groups << group }
    self.connections.current.where.not(group_id: nil).each do |connection|
      _my_groups << connection.group if connection.group
    end
    return _my_groups
  end

  def invites
    self.connections.invites
  end

  def requests
    self.connections.requests
  end
  
  def inbox_unseen
    unseen = 0
    for folder in self.message_folders
      unseen +=1 unless folder.unseen_messages(self).zero?
    end
    return unseen
  end
  
  def folder_between user
    for folder in self.message_folders
      if folder.connections.size.eql? 2 and folder.connections.where(user_id: user.id).present?
        _folder = folder
      end
    end
    return _folder
  end
  
  def message_folders
    folders = []
    self.connections.where.not(connection_id: nil).each do |connection|
      if connection.connection and connection.connection.message_folder
        folders << connection.connection
      end
    end
    return folders
  end
  
  def initialize_settings
    _settings = Setting.names
    # puts names from both categories into one array
    names = _settings[:on]; _settings[:state].each { |name| names << name }
    # creates any new settings not yet initialized
    unless names.size.eql? self.settings.size
      for name in names
        self.settings.create name: name unless self.settings.find_by_name name
      end
    else
      # renames settings based on names array
      i=0; for setting in self.settings
        setting.update name: names[i]; i+=1
      end
    end
  end

  def update_token
    self.generate_token
    self.save
  end

  def generate_token
    begin
      self.auth_token = SecureRandom.urlsafe_base64
    end while User.exists? auth_token: self.auth_token
  end

  def self.authenticate login, password
    user = self.find_by_name login
    # in case the their name is capitalized
    user ||= self.find_by_name login.capitalize
    # in case their name is all lower case
    user ||= self.find_by_name login.downcase
    # in case they're logging in by email
    user ||= self.find_by_email login
    # if user found and password matches decrypted one saved in db
    if user && user.password == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end

    def encrypt_password
      if self.password.present?
        self.password_salt = BCrypt::Engine.generate_salt
        self.password = BCrypt::Engine.hash_secret(self.password, self.password_salt)
      end
    end
end
