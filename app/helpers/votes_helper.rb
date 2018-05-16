module VotesHelper
  def label_to_vote_type label
    case label
    when 'Supporters'
      'for'
    when 'Blockers'
      'against'
    when 'Abstains'
      'abstain'
    end
  end

  def vote_body_text_area_txt vote, new_flip_state=nil
    state = if vote.up?
      "up"
    elsif vote.down?
      "down"
    end
    state = if new_flip_state.eql? 'up'
      "up"
    elsif new_flip_state.eql? 'down'
      "down"
    else
      state
    end
    if state.eql? 'up'
      "Why do you support this proposal? (optional)"
    elsif state.eql? 'down'
      "Why are you blocking this proposal? (optional)"
    end
  end

  def votes_to_reverse? vote
    if vote.up? and vote.proposal.ratified
      ''
    elsif vote.down? and vote.proposal.requires_revision?
      ' block'
    else
      nil
    end
  end

  def vote_can_be_reversed? vote
    humanity_confirmed? and vote.could_be_reversed? anon_token, current_user \
      and ((vote.up? and vote.proposal.ratified) or (vote.down? and vote.proposal.requires_revision?))
  end

  def humanity_confirmed?
    cookies[:simple_captcha_validated].present? or current_user
  end

  def recently_up_voted? proposal
    vote = proposal.up_votes.find_by_anon_token(anon_token)
    return (up_voted? proposal and vote.created_at > 1.hour.ago)
  end

  def voted_on? proposal
    up_voted? proposal or down_voted? proposal or abstained_from_vote? proposal
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

  def abstained_from_vote? proposal
    abstains = proposal.abstains
    if current_user
      abstains.where(user_id: current_user.id).present?
    else
      abstains.where(anon_token: anon_token).present?
    end
  end
end
