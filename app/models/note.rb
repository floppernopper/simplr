class Note < ActiveRecord::Base
  belongs_to :user
  before_create :write_message

  scope :unseen, -> { where seen: [nil, false] }

  def self.notify action, item=nil, receiver=nil, sender=nil
    self.create(
      action: action,
      item_id: (item.is_a?(String) ? nil : (item.nil? ? nil : item.id)),
      # item saved as token if String object given for item argument
      item_token: (item.is_a?(String) ? item : nil),
      # if one of the users is signed up / registered
      user_id: (receiver.is_a?(String) ? nil : (receiver.nil? ? nil : receiver.id)),
      sender_id: (sender.is_a?(String) ? nil : (sender.nil? ? nil : sender.id)),

      # if one of the users is anonymous / not signed up
      anon_token: (receiver.is_a?(String) ? receiver : ((item and !item.is_a?(String) and item.respond_to?(:anon_token) and item.anon_token.present?) ? item.anon_token : nil)),

      sender_token: (sender.is_a?(String) ? sender : nil)
    )
  end

  def action_text action
    _actions = { post_comment: "Someone commented on your post.",
      post_like: "Someone liked your post.",
      post_whoa: "Someone was like whoa to your post.",
      post_love: "Someone loved your post.",
      post_zen: "Someone said your post was very zen.",
      post_share: "Someone shared your post.",
      post_views: "People are seeing your post.",
      profile_view: "Someone viewed your profile.",
      comment_like: "Someone liked your comment.",
      comment_reply: "Someone replied to your comment.",
      also_commented: "Someone also commented on this post.",
      user_mention: "Someone mentioned you in a post.",
      user_mention_comment: "Someone mentioned you in a comment.",
      user_mention_proposal: "Someone mentioned you in a proposal.",
      user_follow: "Someone started following you.",
      message_received: "You've received a message.",
      group_invite: "You've been invited to a group.",
      group_request: "Someone requested to join a group.",
      group_request_accepted: "You're request to join a group was accepted.",
      hype_received: "Someone sent you some H Y P E",
      hype_love_received: "Someone sent you some L O V E",
      user_like: "Someone liked your profile.",
      like_like: "Someone liked your like.",
      # proposal notification actions
      ratified: "Your proposal has been ratified.",
      proposal_up_voted: "Someone supported your proposal.",
      proposal_down_voted: "Someone voted against your proposal.",
      proposal_blocked: "Someone blocked your proposal.",
      revision_submitted: "Someone proposed a revision to your proposal.",
      proposal_revised: "Your proposal has been revised.",
      proposal_comment: "Someone commented on your proposal.",
      proposal_like: "Someone liked your proposal.",
      proposal_views: "People are seeing your motion.",
      vote_verified: "Someone verified your vote.",
      vote_reversed: "Someone reversed your vote.",
      vote_comment: "Someone commented on your vote.",
      vote_like: "Someone liked your vote.",
      # games
      game_challenge: "Someone challenged you to a game.",
      your_turn_in_game: "It's your turn!" }
    return _actions[action.to_sym]
  end

  def item
    if item_id or item_token
      case action.to_sym
      when :post_like, :post_whoa, :post_love, :post_zen, :post_share, :post_views, :user_mention, :post_comment
        Post.find_by_id item_id
      when :profile_view, :user_follow, :user_like
        User.find_by_id item_id
      when :comment_like, :comment_reply, :also_commented, :user_mention_comment
        Comment.find_by_id item_id
      when :message_received
        Connection.find_by_id item_id
      when :group_invite, :group_request, :group_request_accepted
        Group.find_by_id item_id
      when :hype_received, :hype_love_received
        Treasire.find_by_unique_token item_token
      when :like_like
        Like.find_by_id item_id
      when :ratified, :proposal_up_voted, :proposal_down_voted, :proposal_blocked, :revision_submitted, :proposal_revised, :proposal_comment, :proposal_like, :proposal_views, :user_mention_proposal
        Proposal.find_by_unique_token item_token
      when :vote_verified, :vote_reversed, :vote_comment, :vote_like
        Vote.find_by_unique_token item_token
      when :game_challenge, :your_turn_in_game
        Game.find_by_id item_token
      end
    end
  end

  private

  def write_message
    self.message = self.action_text self.action
  end
end
