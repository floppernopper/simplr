class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :share,
    :hide, :open_menu, :close_menu, :add_photoset]
  before_action :secure_post, only: [:edit, :update, :destroy]
  before_action :reset_page_num, only: [:index, :show]
  before_action :invite_only, except: [:show, :create, :add_image, :add_video]
  before_action :invited_or_token_used, only: [:show]
  
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
      Note.notify :post_share, @dup_post, (@post.user ? @post.user : @post.anon_token), current_user
      redirect_to root_url
    else
      redirect_to :back
    end
  end

  def index
    @you_are_home = true
    @all_items = if current_user
      # gets the current users posts, accounts for foc
      current_user.feed forrest_only_club?
    else
      @preview_items = true
      # gets preview items for invitee, accounting for when foc invitee
      Post.preview_posts(invited_to_forrest_only_club?).last(10).reverse
    end
    @items = if @preview_items
      @all_items
    else
      paginate @all_items
    end
    # accessible in other controllers
    $all_items = @all_items # stays constant, only sorted once
    @char_codes = char_codes @items
    @char_bits = char_bits @items
    @post = Post.new
    # records user viewing posts
    @items.each {|item| seent item}
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
      # records views
      seent @post
      # gets views, viewed by users other than current users
      @views = if current_user
        @post.views.where.not user_id: current_user.id
      else
        @post.views
      end
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
        Tag.extract @post #extracts any hashtags along with their position in the text
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
    respond_to do |format|
      format.html { redirect_to root_url }
    end
  end

  private
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
      params.require(:post).permit(:user_id, :group_id, :body, :video, :image, pictures_attributes: [:id, :post_id, :image])
    end
end
