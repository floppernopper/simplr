class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :invite_only, except: [:new, :show, :create, :add_image]
  before_action :invite_only_or_anrcho, only: [:new, :show, :create, :add_image]
  before_action :dev_only, only: [:index]

  def add_image
  end

  def toggle_mini_index
    @item = if params[:proposal]
      Proposal.find_by_unique_token params[:id]
    elsif params[:vote]
      Vote.find_by_unique_token params[:id]
    else
      Post.find_by_id params[:id]
    end
    @comments = @item.comments.last 5 if @item
    @comment = Comment.new
  end

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all.last(20).reverse
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @replying = true
    @reply = Comment.new
    @replies = @comment.replies
    @comment_shown = true
  end

  # GET /comments/new
  def new
    if params[:proposal_id]
      @proposal = Proposal.find_by_id params[:proposal_id]
      @comment = @proposal.comments.new
    else
      @comment = Comment.new
    end
  end

  # GET /comments/1/edit
  def edit
    @editing = true
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.post_id = params[:post_id]
    @comment.comment_id = params[:comment_id]
    @comment.proposal_id = params[:proposal_id]
    @comment.vote_id = params[:vote_id]
    if current_user
      @comment.user_id = current_user.id
    else
      @comment.anon_token = anon_token
    end
    # renders javascript differently for mini and regular forms
    @from_mini_form = true if params[:mini_form] and params[:mini_form].present?
    if @comment.save
      @successfully_created = true
      # extracts and hastags, creates them as db obj
      Tag.extract @comment
      # checks for user mention and notifys mentioned user
      user_mentioned? @comment
      # checks if a reply, notfy and redirects accordingly
      if @comment.comment
        Note.notify :comment_reply, @comment.comment, @comment.comment.user, current_identity \
          unless current_user.eql? @comment.comment.user \
          or (anon_token and anon_token.eql? @comment.anon_token)
        redirect_to @comment.comment
      elsif @comment.post
        @post = @item = @comment.post
        Note.notify :post_comment, @post, @post.user, current_identity \
          unless current_user.eql? @post.user \
          or (anon_token and anon_token.eql? @post.anon_token)
        # notify everyone else that's commented on the post
        for user in @post.commenters
          Note.notify :also_commented, @post, user, current_identity unless current_user and current_user.eql? user
        end
        # only redirects if not ajax
        if @from_mini_form
          @comment = Comment.new
          @comments = @item.comments.last 5
        else
          @comment_just_created = @comment
          @comment = Comment.new
        end
      elsif @comment.proposal
        @proposal = @item = @comment.proposal; prepare_mini_form
        Note.notify :proposal_comment, @proposal.unique_token, @proposal.identity, current_identity \
          unless @proposal.identity.eql? current_identity
        redirect_to show_proposal_path @proposal.unique_token, comments: true unless params[:ajax_req]
      elsif @comment.vote
        @vote = @item = @comment.vote; prepare_mini_form
        Note.notify :vote_comment, @vote.unique_token, @vote.identity, current_identity \
          unless @vote.identity.eql? current_identity
        redirect_to show_vote_path @vote.unique_token unless @from_mini_form
      end
    else
      redirect_to :back
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        Tag.extract @comment
        format.html { redirect_to @comment }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @post = @comment.post
    @comment.destroy
    redirect_to root_url
  end

  private

  def prepare_mini_form
    if @from_mini_form
      @comments = @item.comments.last 5
      @comment = Comment.new
    end
  end

  def dev_only
    redirect_to '/404' unless dev?
  end

  def invite_only_or_anrcho
    unless invited? or anrcho?
      redirect_to '/404'
    end
  end

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:user_id, :post_id, :comment_id, :proposal_id, :vote_id, :body, :image)
  end
end
