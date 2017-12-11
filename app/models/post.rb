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
  validate :unique_share?, on: :create
  
  mount_uploader :image, ImageUploader
  mount_uploader :video, VideoUploader
  mount_uploader :audio, AudioUploader
  
  scope :global, -> { where group_id: nil }
  scope :forrest_only, -> { where forrest_only: true }
  scope :un_invited, -> { where un_invited: true }
  
  def _likes
    self.likes.where love: nil, whoa: nil, zen: nil
  end
  
  def loves
    self.likes.where love: true
  end
  
  def zens
    self.likes.where zen: true
  end
  
  def whoas
    self.likes.where whoa: true
  end
  
  def self.preview_posts forrest_only=nil
    posts = []
    # gets all posts by first user from open groups
    for group in Group.where(open: true)
      for post in group.posts
        posts << post if post.user_id.eql? 1
      end
    end
    # gets all anonymous posts
    for post in Post.where(user_id: nil).where.not(anon_token: nil)
      posts << post unless posts.include? post
    end
    # all of kristins posts
    for post in Post.where(user_id: 34)
      posts << post unless posts.include? post
    end
    # gets all non group proposals not in revision
    for proposal in Proposal.globals.main
      posts << proposal
    end
    # only get foc posts when forrest_only
    posts.delete_if { |item| !item.forrest_only } if forrest_only
    # sorts posts chronologically
    posts.sort_by! { |item| item.created_at }
    return posts.reverse
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
  
  def rank user=nil, feed=nil
    ranked = feed.sort_by { |post| post.score(user) }
    return ranked.index(self) + 1 if ranked.include? self
  end
  
  def score user=nil, get_weights=nil
    weight = 0
    weights = {
      likes: 0, likes_plus: 0,
      comments: 0, comments_plus: 0,
      days: 0, days_plus: 0, fresh: 0,
      in_group: 0,
      shares: 0,
      views: 0,
      classic: 0,
      misc: 0
    }
    
    # likes
    for like in self.likes.where.not(user_id: user.id)
      # recent likes on older posts have more weight
      weights[:likes] += ((like.created_at.to_date - self.created_at.to_date).to_i / 4) + 1
      weights[:likes_plus] += 1 if like.whoa or like.love or like.zen
      weights[:likes_plus] += 5 if like.love and like.user_id.eql?(34) \
        and not self.user_id.eql?(34) # kristin power love
    end # plus one for likes on recent posts to still get valued
    
    # comments
    for comment in self.comments.where.not(user_id: user.id)
      # recent likes on older posts have more weight
      weights[:comments] += ((comment.created_at.to_date - self.created_at.to_date).to_i / 4) + 1
      weights[:comments_plus] += 1 if comment.likes.where.not(user_id: user.id).present?
    end # plus one for likes on recent posts to still get valued
    
    # shares, post shared
    for post in shares # only gives weight for shares of others posts
      weights[:shares] += 1 unless post.user_id and post.user_id.eql? post.original.user_id
    end
    
    # in group you're in
    if self.group and self.group.in_group? user
      weights[:in_group] += 1
      if self.group.creator.eql? user
        weights[:in_group] += 1
      end
    end
    
    # days since posted
    days_old = (Date.today - self.created_at.to_date).to_i
    # older the post, less the weight
    weights[:days] -= days_old.to_i / 2
    # recent posts get more weight
    weights[:days_plus] += 5 if days_old.to_i < 7
    # still fresh posts get even more weight
    weights[:days_plus] += 15 if days_old.to_i < 5
    
    # very fresh posts get even more weight yet
    weights[:fresh] += 25 if days_old.to_i < 2
    weights[:fresh] += 75 if self.created_at > 30.minute.ago
    
    # views by current user
    view = self.views.where(user_id: user.id).last
    if view
      score_count = view.score_count.to_i * 5
      # more weight taken for views on older posts
      score_count *= 15 if self.created_at > 2.week.ago
      weights[:views] -= view.score_count.to_i
    end
    
    # bring back old classics
    if self.created_at < 6.month.ago
      weights[:classic] += 75 if rand(Post.all.size/(Post.where("created_at < ?", 4.months.ago).size/5)).eql? 1
    end
    
    if self.user_id.eql? 20
      weights[:misc] -= 100
    end
    
    # add all weights together
    weights_keys = weights.keys; weights.size.times do |i|
      weight += weights[weights_keys[i]]
    end
    if get_weights
      return weights
    else
      return weight
    end
  end
  
  private
  
  def unique_share?
    # if a share of this post is already present by current user
    if self.original_id and self.original.shares.where(user_id: self.user_id).present?
      errors.add :post, "Share must be unique."
    end
  end
  
  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while Post.exists? unique_token: self.unique_token
  end
    
  def text_or_image?
    if (body.nil? or body.empty?) and (image.url.nil? and not photoset)
      unless original_id and (body.present? or (Post.find_by_id(original_id) \
        and (Post.find(original_id).image.present? or Post.find(original_id).photoset)))
        errors.add(:post, "cannot be empty.") unless video_url or audio_url
      end
    end
  end
end
