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
      anon_token: (receiver.is_a?(String) ? receiver : ((item and !item.is_a?(String) \
        and item.anon_token.present?) ? item.anon_token : nil)),
      sender_token: (sender.is_a?(String) ? sender : nil)
    )
  end
  
  def action_text action
    _actions = { post_comment: "Someone commented on your post.",
      post_like: "Someone liked your post.",
      post_share: "Someone shared your post.",
      comment_like: "Someone liked your comment.",
      comment_reply: "Someone replied to your comment.",
      also_commented: "Someone also commented on this post.",
      user_follow: "Someone started following you.",
      message_received: "You've received a message.",
      group_invite: "You've been invited to a group.",
      group_request: "Someone requested to join a group.",
      group_request_accepted: "You're request to join a group was accepted.",
      hype_received: "Someone sent you some H Y P E",
      # proposal notification actions
      ratified: "Your proposal has been ratified.",
      proposal_blocked: "Someone blocked your proposal.",
      revision_submitted: "Someone proposed a revision to your proposal.",
      proposal_revised: "Your proposal has been revised.",
      commented_vote: "Someone commented on your vote." }
    return _actions[action.to_sym]
  end
  
  private
  
  def write_message
    self.message = self.action_text self.action if self.action.present?
  end
end
