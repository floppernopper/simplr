class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    @replying = true
    @reply = Comment.new
    @replies = @comment.replies
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)
    @comment.post_id = params[:post_id]
    @comment.comment_id = params[:comment_id]
    if current_user
      @comment.user_id = current_user.id
    else
      @comment.anon_token = anon_token
    end
    if @comment.save
      Tag.extract @comment
      if @comment.comment
        Note.notify :comment_reply, @comment.comment, @comment.comment.user, current_user \
          unless current_user.eql? @comment.comment.user
        redirect_to @comment.comment
      elsif @comment.post
        @post = @comment.post
        Note.notify :post_comment, @post, @post.user, current_user unless current_user.eql? @post.user
        unless params[:ajax_req]
          redirect_to @post
        else
          @comment = Comment.new
          @comments = @post.comments.last 5
        end
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
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_url, notice: 'Comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:user_id, :post_id, :comment_id, :body)
    end
end
