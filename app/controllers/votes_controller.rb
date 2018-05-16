class VotesController < ApplicationController
  before_filter :set_vote, only: [:update, :reverse, :verify, :show]
  before_filter :set_proposal, only: [:destroy, :new_up_vote, :new_down_vote, :new_abstain,
      :cast_up_vote, :cast_down_vote, :cast_abstain, :dropdown]

  def update
    if @vote.update(vote_params)
      @vote_updated_successfully = true
      flash.now[:notice] = "Vote was successfully updated."
    else
      flash.now[:notice] = "Vote could not be updated."
    end
  end

  def destroy
    @votes = if params[:unfor]
      @proposal.up_votes
    elsif params[:unabstain]
      @proposal.abstains
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
    if @proposal
      @up_vote = Vote._vote(@proposal, current_user, anon_token, nil, 'up')
    end
  end

  def new_down_vote
    if @proposal
      @down_vote = Vote._vote(@proposal, current_user, anon_token, nil, 'down')
    end
  end

  def new_abstain
    if @proposal
      @abstain = Vote._vote(@proposal, current_user, anon_token, nil, 'abstain')
    end
  end

  def cast_up_vote
    @up_vote = Vote._vote(@proposal, current_user, anon_token, params[:body], 'up')
    Tag.extract @up_vote
    if @up_vote
      @vote_cast_successful = true
      Note.notify :proposal_up_voted, @proposal.unique_token, (@proposal.user ? @proposal.user : @proposal.anon_token),
        (@up_vote.user ? @up_vote.user : @up_vote.anon_token)
    end
  end

  def cast_down_vote
    @down_vote = Vote._vote(@proposal, current_user, anon_token, params[:body], 'down')
    Tag.extract @down_vote
    if @down_vote
      @vote_cast_successful = true
      Note.notify :proposal_down_voted, @proposal.unique_token, (@proposal.user ? @proposal.user : @proposal.anon_token),
        (@down_vote.user ? @down_vote.user : @down_vote.anon_token)
    end
  end

  def cast_abstain
    @abstain = Vote._vote(@proposal, current_user, anon_token, params[:body], 'abstain')
    Tag.extract @abstain
    if @abstain
      @vote_cast_successful = true
      Note.notify :proposal_abstained, @proposal.unique_token, (@proposal.user ? @proposal.user : @proposal.anon_token),
        (@abstain.user ? @abstain.user : @abstain.anon_token)
    end
  end

  def reverse
    if @vote.could_be_reversed? anon_token, current_user
      vote = @vote.votes.new flip_state: 'down', anon_token: anon_token
      vote.user_id = current_user.id if current_user
      if vote.save
        # for ajax card replace
        @success = true
      end
      if @vote.votes_to_reverse <= 0
        if @vote.up?
          @vote.proposal.update ratified: false
        elsif @vote.down?
          @vote.proposal.update requires_revision: false
        end
        @vote.update verified: false
        @vote.votes.destroy_all
        Note.notify :vote_reversed, @vote.unique_token,
          (@vote.user ? @vote.user : @vote.anon_token),
          (current_user ? current_user : anon_token)
      end
    end
  end

  def verify
    if cookies[:simple_captcha_validated].present? or current_user
      if @vote.verifiable? anon_token, current_user and not @vote.proposal.requires_revision
        @vote.update verified: true
        @vote.proposal.evaluate
        Note.notify :vote_verified, @vote.unique_token,
          (@vote.user.nil? ? @vote.anon_token : @vote.user),
          (current_user ? current_user : anon_token)
        @success = true
      end
    end
  end

  def confirm_humanity
    if simple_captcha_valid?
      cookies.permanent[:simple_captcha_validated] = true
    end
    redirect_to :back
  end

  def show
    @comments = @vote.comments
    @comment = Comment.new
    seent @vote
    # gets views, viewed by users other than current users
    @views = if current_user
      @vote.views.where.not user_id: current_user.id
    else
      @vote.views
    end
    # filters any views by the OP, of course they saw, they posted it
    @views = @views.where.not(user_id: @vote.user_id) if @vote.user_id
    # gets any likes for the motion
    @likes = @vote.likes
  end

  private

  def set_vote
    @vote = Vote.find_by_unique_token(params[:token])
  end

  def set_proposal
    @proposal = Proposal.find_by_unique_token(params[:token])
    @up_votes = @proposal.up_votes
    @down_votes = @proposal.down_votes
    @abstains = @proposal.abstains
    @votes = @proposal.votes
  end

  def vote_params
    params.require(:vote).permit(:body, :flip_state)
  end
end
