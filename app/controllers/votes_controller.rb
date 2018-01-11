class VotesController < ApplicationController
  def destroy
    @proposal = Proposal.find_by_unique_token(params[:token])
    @votes = if params[:unfor]
      @proposal.up_votes
    else
      @proposal.down_votes
    end
    @vote = if current_user
      @votes.where(user_id: current_user.id).last
    else
      @votes.where(anon_token: anon_token).last
    end
    @vote.destroy if @vote
  end
  
  def new_up_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    if @proposal
      @up_vote = Vote.up_vote(@proposal, current_user, anon_token)
    end
  end
  
  def new_down_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    if @proposal
      @down_vote = Vote.down_vote(@proposal, current_user, anon_token)
    end
  end
  
  def cast_up_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    @up_vote = Vote.up_vote(@proposal, current_user, anon_token, params[:body])
    Tag.extract @up_vote
    if @up_vote
      Note.notify :proposal_up_voted, @proposal.unique_token, (@proposal.user ? @proposal.user : @proposal.anon_token),
        (@up_vote.user ? @up_vote.user : @up_vote.anon_token)
    end
  end
  
  def cast_down_vote
    @proposal = Proposal.find_by_unique_token(params[:token])
    @down_vote = Vote.down_vote(@proposal, current_user, anon_token, params[:body])
    Tag.extract @down_vote
    if @down_vote
      Note.notify :proposal_down_voted, @proposal.unique_token, (@proposal.user ? @proposal.user : @proposal.anon_token),
        (@down_vote.user ? @down_vote.user : @down_vote.anon_token)
    end
  end
  
  def reverse
    @vote = Vote.find_by_unique_token params[:token]
    if @vote.could_be_reversed? anon_token, current_user
      vote = @vote.votes.new flip_state: 'down', anon_token: anon_token
      vote.user_id = current_user.id if current_user; vote.save
      if @vote.votes_to_reverse <= 0
        if @vote.up?
          @vote.proposal.update ratified: false
        elsif @vote.down?
          @vote.proposal.update requires_revision: false
        end
        @vote.update verified: false
        @vote.votes.destroy_all
        Note.notify :vote_reversed, @vote.unique_token,
          (@vote.user ? user : @vote.anon_token),
          (current_user ? current_user : anon_token)
      end
    end
    redirect_to :back
  end
  
  def verify
    if cookies[:simple_captcha_validated].present? or current_user
      @vote = Vote.find_by_unique_token params[:token]
      if @vote.verifiable? anon_token, current_user and not @vote.proposal.requires_revision
        @vote.update verified: true
        @vote.proposal.evaluate
        Note.notify :vote_verified, @vote.unique_token,
          (@vote.user.nil? ? @vote.anon_token : @vote.user),
          (current_user ? current_user : anon_token)
      end
    end
    redirect_to :back
  end
  
  def confirm_humanity
    if simple_captcha_valid?
      cookies.permanent[:simple_captcha_validated] = true
    end
    redirect_to :back
  end
  
  def show
    @vote = Vote.find_by_unique_token params[:token]
    @comments = @vote.comments
    @comment = Comment.new
  end
end
