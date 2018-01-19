class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :share,
    :hide, :open_menu, :close_menu, :add_photoset, :classify]
  before_action :secure_post, only: [:edit, :update, :destroy]
  before_action :reset_page_num, only: [:index, :show]
  before_action :invite_only, except: [:show, :create, :add_image, :add_video]
  before_action :invited_or_token_used, only: [:show]
  
  before_action :dev_only, only: [:classify]
  
  def classify
    @picture = @post.pictures.first
    notice = if @picture.classify
      "Picture classification successful."
    else
      "Picture classification failed."
    end
  end
  
  def floating_images
    @user = User.find_by_unique_token params[:token]
    @posts = @user.posts.first(100).select { |p| p.pictures.present? }
  end
  
  def play_audio
    @post = Post.find_by_id params[:id]
  end
  
  def read_more
    @post = Post.find_by_id params[:post_id]
  end

  def open_menu
  end

  def close_menu
  end

  def add_group_id
  end

  def add_video
  end

  def add_image
  end

  def add_audio
  end

  def add_photoset
  end

  def remove_picture
    @picture_id = params[:picture_id]
    @picture = Picture.find_by_id @picture_id
    @picture.destroy
  end

  def hide
    @post.update hidden: true
    redirect_to root_url
  end

  def share
    @dup_post = @post.dup
    @dup_post.user_id = current_user.id
    # assigns id of shared post or the original if present
    @dup_post.original_id = if @post.original_id
      @post.original_id
    else
      @post.id
    end
    @dup_post.group_id = nil
    if @dup_post.save
      Tag.extract @dup_post
      # gets the true original post
      original_post = @post.original ? @post.original : @post
      if current_user and not current_user.eql? @post.user # only notify for sharing others posts
        Note.notify :post_share, @dup_post, (original_post.user ? original_post.user : original_post.anon_token), current_user
        @note = if original_post.user
          "You shared #{original_post.user.name}'s post."
        else
          "You shared an anonymous post."
        end
      else
        @note = "You shared a memory."
      end
    end
  end
  
  def load_index
    # ensuring loader only shows once per session
    session[:loading_loader_seen] = true
    run_for_main_feed
  end

  def index
    @post = Post.new
    @you_are_home = true
    @down = false # turn on for testing/maintence
    if session[:loading_loader_seen]
      # gets everything for main feed
      run_for_main_feed
    end
    # records current time for last visit
    record_last_visit
  end

  def show
    if @post and params[:token].to_s.size >= 4
      @post_shown = true
      @comment = Comment.new
      @comments = @post.comments
      # manifests table flipping/resetting bot
      Bot.manifest_bots [:reset_table, :grow],
        { comments: @comments, page: request.original_url }
      @likes = @post._likes
      @loves = @post.loves
      @whoas = @post.whoas
      @zens = @post.zens
      @shares = if @post.original
        @post.original.shares
      else
        @post.shares
      end
      # records views
      seent @post
      # gets views, viewed by users other than current users
      @views = if current_user
        @post.views.where.not(user_id: current_user.id)
      else
        @post.views
      end
      # filters any views by the OP, of course they saw, they posted it
      @views = @views.where.not(user_id: @post.user_id) if @post.user_id
    else
      redirect_to '/404'
    end
  end

  def new
    @post = Post.new
  end

  def edit
    @editing = true
  end

  def create
    sorta_secure = invited? or anrcho? or current_user
    if !sorta_secure and not params[:un_invited]
      redirect_to '/404'
    end
    @post = Post.new(post_params)
    @group = Group.find_by_id params[:group_id]
    # check to see if user is a member of group if ones selected
    @post.group_id = @group.id if current_user and @group and \
      (current_user.my_groups.include? @group or @group.user.eql? current_user)
    if current_user
      @post.user_id = current_user.id
    else
      @post.anon_token = anon_token
    end
    # sets as photoset for validation
    if params[:pictures]
      @post.photoset = true
    end
    # for users not yet invited, from the invite only page
    if params[:un_invited] and not sorta_secure
      @post.un_invited = true
      @post.anon_token = $name_generator.next_name + "_" + SecureRandom.urlsafe_base64
    end
    respond_to do |format|
      if @post.save
        if params[:pictures]
          # builds photoset for post
          params[:pictures][:image].each do |image|
            @post.pictures.create image: image
          end
        end
        # extracts any hashtags along with their position in the text
        Tag.extract @post
        # prepares vars for ajax create.js
        #@successfully_created = true
        #@post_just_created = @post
        #@post = Post.new
        format.html { redirect_to (@post.group.present? ? @post.group : root_url) }
      else
        format.html { redirect_to root_url }
      end
    end
  end

  def update
    if @post.update(post_params.except(:group_id))
      if params[:group_id].present?
        @post.update group_id: params[:group_id]
      end
      if params[:pictures]
        params[:pictures][:image].each do |image|
          @post.pictures.create image: image
        end
      end
      Tag.extract @post
      redirect_to show_post_path @post.unique_token
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    unless params[:ajax_req]
      respond_to do |format|
        format.html { redirect_to root_url }
      end
    end
  end

  private
  
  def dev_only
    unless dev?
      redirect_to '/404'
    end
  end
  
  # everything required to render main feed
  def run_for_main_feed
    # for recent anrcho spam
    Proposal.filter_spam
    @all_items = if current_user
      current_user.feed
    else
      @preview_items = true
      Post.preview_posts
    end
    @items = paginate @all_items
    # accessible for other controllers
    $all_items = @all_items # stays constant, only sorted once
    @char_codes = char_codes @items
    @char_bits = char_bits @items
    # records user viewing posts
    @items.each {|item| seent item}
  end
  
  def invited_or_token_used
    unless invited? or (params[:token] and params[:token].size > 4)
      redirect_to '/404'
    end
  end

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end

  def secure_post
    set_post
    params_size = if params[:token] then params[:token].to_s.size else params[:id].to_s.size end
    unless current_user.eql? @post.user or (anon_token and anon_token.eql? @post.anon_token) or dev? or params_size >= 4
      redirect_to '/404'
    end
  end

  def reset_page_num
    reset_page
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    if params[:token]
      @post = Post.find_by_unique_token(params[:token])
      @post ||= Post.find_by_id(params[:token])
    else
      @post = Post.find_by_unique_token(params[:id])
      @post ||= Post.find_by_id(params[:id])
    end
    redirect_to '/404' unless @post
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:user_id, :group_id, :body, :video, :image, :audio, :audio_name,
      pictures_attributes: [:id, :post_id, :image])
  end
end
