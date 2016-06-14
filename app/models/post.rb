class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :pictures, dependent: :destroy
  
  accepts_nested_attributes_for :pictures
  
  before_create :gen_unique_token
  
  validate :text_or_image?, on: :create
  
  mount_uploader :image, ImageUploader
  
  scope :global, -> { where group_id: nil }
  
  def self.preview_posts
    posts = []
    for group in Group.where(open: true)
      for post in group.posts
        posts << post
      end
    end
    return posts.sort
  end
  
  def commenters
    _commenters = []
    for comment in self.comments
      unless comment.user and _commenters.include? comment.user or comment.anon_token.present?
        _commenters << comment.user
      end
    end
    return _commenters
  end
  
  def shares
    Post.where original_id: self.id
  end
  
  def original
    Post.find_by_id self.original_id
  end
  
  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
    
    def text_or_image?
      if (body.nil? or body.empty?) and (image.url.nil? and not photoset)
        unless original_id and (body.present? or (Post.find_by_id(original_id) \
          and (Post.find(original_id).image.present? or Post.find(original_id).photoset)))
          errors.add(:post, "cannot be empty.")
        end
      end
    end
end
