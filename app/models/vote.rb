class Vote < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :comment
  belongs_to :vote
  
  has_many :comments
  has_many :votes
  has_many :tags
  
  before_create :gen_unique_token
  
  def votes_to_reverse
    self.proposal.ratification_threshold - self.votes.where(flip_state: 'down').size
  end
  
  def could_be_reversed? token
    could_be = false
    if self.verified
      unless (self.votes.find_by_anon_token token or self.proposal.anon_token.eql? token)
        could_be = true
      end
    end
    return could_be
  end
  
  def verifiable? current_token
    _verifiable = false
    unless self.verified
      if self.unique_token.present?
        unless current_token.eql? self.anon_token
          _verifiable = true
        end
      end
    end
    return _verifiable
  end
  
  def self.up_vote obj, token, body=""
    unless token.eql? obj.anon_token
      vote = obj.votes.find_by_anon_token(token) if obj.votes.find_by_anon_token(token)
      if not vote
        vote = obj.votes.create flip_state: 'up', anon_token: token, body: body
      else
        vote.body = body if body.present?
        vote.flip_state = 'up'
        vote.save
      end
      obj.evaluate
    end
    return vote
  end
  
  def self.down_vote obj, token, body=""
    unless token.eql? obj.anon_token
      vote = obj.votes.find_by_anon_token(token) if obj.votes.find_by_anon_token(token)
      if not vote
        vote = obj.votes.create flip_state: 'down', anon_token: token, body: body
      else
        vote.body = body if body.present?
        vote.flip_state = 'down'
        vote.save
      end
      obj.evaluate
    end
    return vote
  end
  
  def self.score obj
    up_votes_weight = 0
    for vote in obj.votes.up_votes
      # recent votes on older proposals have more weight
      up_votes_weight += ((vote.created_at.to_date - obj.created_at.to_date).to_i / 2) + 1
    end # plus one for votes on recent proposals to still get valued
    points = up_votes_weight + obj.comments.size / 2
    points -= (Date.today - obj.created_at.to_date).to_i / 2
    points -= obj.views.size / 10 # raise the obscure to top
    # adds weight for clusters of votes close together in time
    points += obj.votes.up_votes.hotness
    return points
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
