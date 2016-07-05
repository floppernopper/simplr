class Group < ActiveRecord::Base
  belongs_to :user
  
  has_many :posts, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :settings, dependent: :destroy
  has_many :connections, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :treasures
  
  before_create :gen_unique_token, :gen_passphrase

  mount_uploader :image, ImageUploader
  
  scope :global, -> { where.not(name: nil).where anon_token: nil }
  scope :anrcho, -> { where.not(anon_token: nil).where name: nil }
  
  def self.delete_all_old
    # ephemerality for all anrcho groups
    anrcho.delete_all "created_at < '#{1.week.ago}'"
  end
  
  def expires?
    if (self.expires_at.nil? and self.created_at.to_date < 1.week.ago) \
      or (self.expires_at.present? and self.expires_at < DateTime.current) \
      or (self.view_limit.present? and self.views.size >= self.view_limit)
      self.destroy!
      return true
    else
      return false
    end
  end
  
  def active_chat?
    self.messages.present? and self.messages.last.created_at > 5.minute.ago
  end
  
  def members_size
    size = self.members.size
    size +=1 if self.creator
    return size
  end

  def creator
    if self.user
      return self.user
    else
      return self.anon_token
    end
  end

  def invite_to_join _user
    invite = self.connections.create user_id: _user.id, invite: true
  end

  def remove _user
    connection = self.connections.find_by_user_id _user.id
    connection.destroy if connection
  end

  def members
    self.connections.current
  end

  def invites
    self.connections.invites
  end

  def requests
    self.connections.requests
  end
  
  private
    def gen_passphrase
      if self.pass_protected
        pass = Passphrase::Passphrase.new(
          number_of_words: 1, languages: ["english"]
        ); pass = pass.passphrase.to_s.to_p
        self.passphrase = pass
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
