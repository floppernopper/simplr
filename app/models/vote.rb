class Vote < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :comment
  belongs_to :vote
  belongs_to :user
  
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :likes, dependent: :destroy
  
  before_create :gen_unique_token
  
  def _likes
    self.likes.where love: nil, whoa: nil, zen: nil
  end
  
  def votes_to_reverse
    self.proposal.ratification_threshold - self.votes.where(flip_state: 'down').size
  end
  
  def could_be_reversed? token, user
    could_be = false
    if self.verified
      unless (self.votes.find_by_anon_token token or self.proposal.anon_token.eql? token) \
        or (user and (self.votes.find_by_user_id user.id or self.proposal.user.eql? user))
        could_be = true
      end
    end
    return could_be
  end
  
  def verifiable? token, user
    _verifiable = false
    unless self.verified
      if self.unique_token.present?
        unless token.eql? self.anon_token or (user and self.user.eql? user)
          _verifiable = true
        end
      end
    end
    return _verifiable
  end
  
  def self.up_vote obj, user, token, body=""
    unless (token and token.eql? obj.anon_token) or (user and user.id.eql? obj.user_id)
      vote = if token
        obj.votes.find_by_anon_token token
      elsif user
        obj.votes.find_by_user_id user.id
      end
      if not vote
        vote = obj.votes.new flip_state: 'up', anon_token: token, body: body
        vote.user_id = user.id if user
        vote.save
      else
        vote.body = body if body.present?
        vote.flip_state = 'up'
        vote.save
      end
      obj.evaluate
    end
    return vote
  end
  
  def self.down_vote obj, user, token, body=""
    unless (token and token.eql? obj.anon_token) or (user and user.id.eql? obj.user_id)
      vote = if token
        obj.votes.find_by_anon_token token
      elsif user
        obj.votes.find_by_user_id user.id
      end
      if not vote
        vote = obj.votes.new flip_state: 'down', anon_token: token, body: body
        vote.user_id = user.id if user
        vote.save
      else
        vote.body = body if body.present?
        vote.flip_state = 'down'
        vote.save
      end
      obj.evaluate
    end
    return vote
  end
  
  def self.score obj, get_weights=nil
    weight = 0
    weights = {up_votes: 0, comments: 0, days_old: 0, views: 0, hotness: 0}
    up_votes_weight = 0; for vote in obj.votes.up_votes
      # recent votes on older proposals have more weight
      if vote.created_at.to_date < 2.week.ago
        up_votes_weight += ((vote.created_at.to_date - obj.created_at.to_date).to_i / 2) + 1
      end
    end # plus one for votes on recent proposals to still get valued
    weights[:up_votes] += up_votes_weight / 4
    weights[:comments] += obj.comments.size / 2 # accounts for comments
    # number of days since posted
    weights[:days_old] -= (Date.today - obj.created_at.to_date).to_i / 2
    weights[:views] -= obj.views.size / 10 # raise the obscure to top
    # adds weight for clusters of votes close together in time
    weights[:hotness] += obj.votes.up_votes.hotness
    # add all weights together
    weights_keys = weights.keys; weights.size.times do |i|
      weight += weights[weights_keys[i]]
    end
    if get_weights
      # hash returned
      return weights
    else
      # total weights returned
      return weight
    end
  end
  
  def up?
    self.flip_state.eql? 'up'
  end
  
  def down?
    self.flip_state.eql? 'down'
  end
  
  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
    
    def self.hotness
      total = 0
      for vote in self.all
        next_vote = self.all.find_by_id(vote.id + 1); if next_vote.nil? then break end
        total += 1 if vote.created_at.to_date > 1.days.ago \
          and (vote.created_at.to_date - next_vote.created_at.to_date).to_i.zero?
      end
      avg = total.nonzero? ? self.all.size / total : nil
      return avg ? avg : 0
    end
    
    def self.verified
      where verified: true
    end
    
    def self.up_votes
      where flip_state: 'up'
    end
    
    def self.down_votes
      where flip_state: 'down'
    end
end
