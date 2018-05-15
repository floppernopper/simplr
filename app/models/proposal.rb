class Proposal < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :group
  belongs_to :user

  has_many :proposals, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :pictures, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :views, dependent: :destroy
  has_many :likes, dependent: :destroy

  accepts_nested_attributes_for :pictures

  before_create :gen_unique_token
  before_save :spam_filter
  before_update :not_voted_on
  validates_presence_of :body

  scope :main, -> { where requires_revision: [nil, false] }
  scope :globals, -> { where(group_id: nil).where.not action: :revision }
  scope :voting, -> { where(ratified: [nil, false]).where requires_revision: [nil, false] }
  scope :revision, -> { where requires_revision: true }
  scope :ratified, -> { where ratified: true }

  mount_uploader :image, ImageUploader

  def evaluate
    if ratifiable?
      self.ratify!
      puts "\nProposal #{self.id} was ratified!"
      return true
    elsif requires_revision?
      self.update requires_revision: true
      puts "\nProposal #{self.id} now requires revision."
      Note.notify :proposal_blocked, self.unique_token, (self.user ? self.user : self.anon_token)
      return nil
    elsif self.revised
      puts "\nProposal #{self.id} has been deprecated."
    end
  end

  def ratify!
    # for revision proposals
    if self.proposal
      case action.to_sym
      when :revision
        Note.notify :proposal_revised, self.unique_token, (self.user ? self.user : self.anon_token)
        # creates new obj dup as reivision is only an intermediary phase to the next version
        # what happens to ratified revision motion?
        new_version = self.proposal.dup
        new_version.assign_attributes({
          requires_revision: false,
          action: self.revised_action,
          version: self.version,
          title: self.title,
          body: self.body,
          # to stay in group if present
          group_id: self.group_id,
          # also very important to most actions
          misc_data: self.misc_data
          # needs imgs as well, with img model
        })
        if new_version.save
          # sets values to finish revision
          self.proposal.update(
            # old version now ties back to new one
            proposal_id: new_version.id,
            # officially revised
            revised: true
          )
        end
      end
    # proposals to groups
    elsif self.group
      case action.to_sym
      when :disband_early
        self.group.destroy!
      when :postpone_expiration
        self.group.update expires_at: (Date.today + 14).to_s
      when :set_ratification_threshold
        self.group.update ratification_threshold: 25
      when :limit_views
        self.group.update view_limit: 3
      when :grant_title
      when :update_name
        self.group.update name: self.misc_data
      when :update_description
        self.group.update body: self.misc_data
      when :update_social_structure
        self.group.update social_structure: self.misc_data
      when :create_bot
        bot = self.group.bots.new
        bot.save
      end
    # global proposals
    else
      case action.to_sym
      when :update_manifesto
      when :meetup
      end
    end
    self.update ratified: true
    Note.notify :ratified, self.unique_token, (self.user ? self.user : self.anon_token)
    puts "\nProposal #{self.id} has been ratified.\n"
    self.tweet if ENV['RAILS_ENV'].eql? 'production'
  end

  def rank user=nil, feed=nil
    proposals = self.group.present? ? self.group.proposals : Proposal.globals
    ranked = proposals.sort_by { |proposal| proposal.score }
    return ranked.reverse.index(self) + 1 if ranked.include? self
  end

  def score user=nil, feed=nil, get_weights=nil
    Vote.score(self, get_weights)
  end

  def self.action_types
    { general: "General statement or idea",
      direct_action: "Plan some direct action",
      cooperative: "Form a cooperative",
      meetup: "Local meetup",
      debate: "Debate",
      update_manifesto: "New manifesto",
      request_feature: "New feature",
      bug_fix: "Fix to a bug",
      just_a_test: "Test motion",
      grant_title: "Grant title" }
  end

  def self.group_action_types
    { add_hashtags: "Add hashtags",
      update_name: "Update group name",
      update_banner: "Update group banner",
      update_description: "Update group description",
      update_social_structure: "Update group social structure",
      add_locale: "Set your locale as the groups",
      disband_early: "Disband, effective immediately",
      postpone_expiration: "Postpone expiration of the group",
      set_ratification_threshold: "Set ratification threshold to 25",
      update_manifesto: "Update group manifesto",
      limit_views: "Expire at view limit of 3",
      create_bot: "Create a voter bot",
      grant_title: "Grant title",
      debate: "Debate" }
  end

  def votes_to_ratify
    # also accounts for non verified votes as well, as half votes, since no peer review
    (self.ratification_threshold - (self.verified_up_votes.size + (self.up_votes.size / 2))).to_i + 1
  end

  def requires_revision?
    self.verified_down_votes.size > 0 and not self.revised
  end

  def ratifiable?
    # also accounts for non verified votes as well, as half votes, since no peer review
    !self.ratified and !(self.proposal.present? and self.proposal.revised) and self.verified_down_votes.size.zero? \
      and (self.verified_up_votes.size + (self.up_votes.size / 2)) > self.ratification_threshold
  end

  def ratification_threshold
    # dynamic threshold able to be set by group proposal
    _threshold = if self.group and self.group.ratification_threshold.present?
      self.group.ratification_threshold
    else
      5
    end
    # views for group (instead of motion views) if present
    _views = if self.group
      self.group.views
    else
      self.views
    end
    # uses views as threshold if higher
  	if _views.size > _threshold
  		return _views.size / 5
  	else
  		return _threshold / 2
  	end
  end

  def verified_up_votes
    self.up_votes.where verified: true
  end

  def verified_down_votes
    self.down_votes.where verified: true
  end

  def up_votes
    self.votes.up_votes.where moot: [nil, false]
  end

  def down_votes
    self.votes.down_votes.where moot: [nil, false]
  end

  def abstains
    self.votes.abstains
  end

  def seent current_token
    unless self.seen? current_token
      self.views.create token: current_token
    end
  end

  def seen? current_token
    if self.views.find_by_token current_token
      return true
    else
      return false
    end
  end

  def revisions
    self.proposals.where action: "revision"
  end

  # all proposals need to be updated as version 1 before this can work
  # unless database started with version 1 proposals by default
  def old_versions
    versions = self.proposals.where.not(action: "revision").
      where("version < '#{ self.version.to_i }'").sort_by do |version|
        version.version
      end
    return versions
  end

  def identity
    return user if user
    return anon_token if anon_token
  end

  def able_to_edit?
    self.votes.empty?
  end

  def _likes
    self.likes.where love: nil, whoa: nil, zen: nil
  end

  def tweet
    message = ""
    insert = lambda { |char| message << char if message.size < 140 }
    # inserts title into message
    self.title.split("").each do |char|
      insert.call char
    end
    insert.call " "
    # inserts body, breaks at hashtags
    self.body.split("").each do |char|
      break if char.eql? '#'
      insert.call char
    end
    insert.call " "
    # inserts tags if room
    self.tags.each do |tag|
      break unless tag.tag.size + message.size < 140
      tag.tag.split("").each do |char|
        insert.call char
      end
      insert.call " "
    end
    # checks in case api keys aren't present
    if ENV['TWITTER_CONSUMER_KEY'].present?
      $twitter.update message
    else
      puts "Twitter API keys are not present."
    end
  end

  def self.filter_spam
    for proposal in self.all
      if proposal.is_spam?
        proposal.destroy
      end
    end
  end

  def is_spam?
    for i in [self.title.to_s, self.body.to_s]
      if i.include? "business" or i.include? "capital" or i.include? "fund"
        return true
      end
    end
    nil
  end

  private

  def not_voted_on
    if votes.present?
      errors.add(:proposal, "cannot be voted on.")
    end
  end

  def spam_filter
    if self.is_spam?
      errors.add(:proposal, "cannot be spam")
    end
  end

  def gen_unique_token
    begin
      self.unique_token = SecureRandom.urlsafe_base64
    end while Proposal.exists? unique_token: self.unique_token
  end
end
