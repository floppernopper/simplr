module VotesHelper
  def humanity_confirmed?
    cookies[:simple_captcha_validated].present? or current_user
  end
  
  def recently_up_voted? proposal
    vote = proposal.up_votes.find_by_anon_token(anon_token)
    return (up_voted? proposal and vote.created_at > 1.hour.ago)
  end
  
  def up_voted? proposal
    up_votes = proposal.up_votes
    if current_user
      up_votes.find_by_user_id(current_user.id)
    else
      up_votes.find_by_anon_token(anon_token)
    end
  end
  
  def down_voted? proposal
    down_votes = proposal.down_votes
    if current_user
      down_votes.where(user_id: current_user.id).present?
    else
      down_votes.where(anon_token: anon_token).present?
    end
  end
end
