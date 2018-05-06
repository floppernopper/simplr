class ProposalsController < ApplicationController
  before_filter :set_proposal, only: [:old_versions, :show, :destroy]
  # turn off invite only for anrcho before_action :invite_only
  before_filter :bots_to_404

  def add_form
    @group = Group.find_by_id params[:group_id]
    @proposal = if @group then @group.proposals.new else Proposal.new end
    @post = if @group then @group.posts.new else Post.new end
  end

  def contributors
  end

  def tutorial
  end

  def old_versions
    @old_versions = @proposal.old_versions
  end

  def load_section_links
    @group = Group.find_by_token(params[:group_token])
  end

  def add_group_token
  end

  def add_image
  end

  def index
    @anrcho = true
    cookies[:anrcho] = true
    @proposal = Proposal.new
#    if current_user
#      # if user had visited social_maya via anrcho
#      cookies.delete(:auth_token)
#    end
    # for use in development
    # cookies.permanent[:at_anrcho] ||= true.to_s
    build_feed :main
    # grants Power of Anarchy
    if current_user and not current_user.has_power? 'anarchy'
      treasure = current_user.treasures.new power: 'anarchy'
      # can now make motions and proposals from homepage
      treasure.save
    end
  end

  def new
    @proposal = Proposal.new
    @parent_proposal = Proposal.find_by_id(params[:proposal_id])
    @group = Group.find_by_id(params[:group_id])
  end

  def create
    @proposal = Proposal.new(proposal_params)
    @proposal.user_id = current_user.id if current_user
    @proposal.group_id = params[:group_id]
    @proposal.anon_token = anon_token

    if @proposal.action.eql? "grant_title"

    end

    build_action
    if @proposal.save
      Tag.extract @proposal
      if @proposal.proposal
        Note.notify :revision_submitted, @proposal.proposal.unique_token
        redirect_to show_proposal_path(token: @proposal.proposal.unique_token, revisions: true)
      elsif @proposal.group
        redirect_to show_group_path(@proposal.group.unique_token)
      else
        redirect_to proposals_path
      end
    else
      redirect_to :back
    end
  end

  def show
    @group = @proposal.group if @proposal
    if @proposal
      @proposal_shown = true
      seent @proposal

      # gets all votes for and against
      @up_votes = @proposal.up_votes
      @down_votes = @proposal.down_votes
      @votes = @proposal.votes

      # gets all comments/discussion
      @comments = @proposal.comments
      @comment = Comment.new

      # gets any revisions to proposal
      @revisions = @proposal.proposals
      @revision = Proposal.new

      # gets views, viewed by users other than current users
      @views = if current_user
        @proposal.views.where.not user_id: current_user.id
      else
        @proposal.views
      end
      # filters any views by the OP, of course they saw, they posted it
      @views = @views.where.not(user_id: @proposal.user_id) if @proposal.user_id
      # gets any likes for the motion
      @likes = @proposal.likes

      @old_versions = @proposal.old_versions

      if params[:revisions] and @proposal.requires_revision
        @show_revisions = true
      elsif params[:comments] or @votes.empty?
        @show_comments = true
      else
        @show_votes = true
      end

      @proposal.evaluate
    else
      redirect_to '/404'
    end
  end

  def destroy
    @proposal.destroy
    redirect_to root_url
  end

  # Proposal sections: :voting, :revision, :ratified
  def switch_section
    @group = Group.find_by_unique_token params[:group_token]
    build_feed params[:section], @group
  end

  # Sub sections: :votes, :comments
  def switch_sub_section
    redirect_to :back
  end

  private

  def bots_to_404
    redirect_to '/404' if request.bot?
  end

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end

  def set_proposal
    @proposal = Proposal.find_by_unique_token(params[:token])
  end

  def build_feed section, group=nil
    build_proposal_feed section, group
  end

  def build_action
    action = params[:proposal][:action]
    action = params[:proposal_action] unless action.present?
    case (action.present? ? action : "").to_sym
    when :add_locale, :meetup
      @proposal.misc_data = request.remote_ip.to_s
    when :revision
      @proposal.action = "revision"
      # revision belongs to motion that it's revising
      @proposal.proposal_id = params[:proposal_id]
      @proposal.revised_action = params[:revised_action]
      # where versioning happens, gets blocked proposals version + 1, when a revision
      @proposal.version = Proposal.find(params[:proposal_id]).version.to_i + 1
    when :grant_title
      grant = {title: nil, days_alive: nil}
      grant[:title] = params[:title]
      grant[:days_alive] = params[:days_alive]
      @proposal.misc_data = grant.to_s
    when :update_name
    end
  end

  def proposal_params
    params[:proposal].permit(:title, :body, :action, :image, :misc_data)
  end
end
