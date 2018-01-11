class Secret < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :secret
  belongs_to :treasure
  
  has_many :secrets
  has_many :treasures
  has_many :game_pieces
  
  before_create :gen_unique_token

  mount_uploader :image, ImageUploader
  
  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
