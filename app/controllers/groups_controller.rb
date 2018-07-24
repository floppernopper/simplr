class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy, :load_more_posts]
  before_action :secure_group, only: [:edit, :update, :destroy]
  before_action :dev_only, only: [:index]
  before_action :invite_only, except: [:new, :create, :update, :destroy, :show, :edit, :my_anon_groups]
  before_action :invited_or_anrcho, only: [:new, :create, :show]
  before_action :anrcho_only, only: [:my_anon_groups]

  def load_more_posts
    build_feed
    @items = paginate @items
    page_turning @items
  end

  def hide_featured_groups
    cookies.permanent[:hide_featured_groups] = true
  end

  def their_groups
    @user = User.find_by_id params[:user_id]
    @groups = @user.my_groups.reverse
    redirect_to my_groups_path if @user.eql? current_user
  end

  def my_groups
    @group = Group.new
  end

  def my_anon_groups
    unless current_user
      Group.delete_all_old
      @group = Group.new
      # a list of all groups viewed so far
      views = View.where(anon_token: anon_token).where.not(group_id: nil)
      @groups = []; for view in views
        if view.group and view.group.anon_token and not view.group.expires?
          @groups << view.group unless @groups.include? view.group
        end
      end
      Group.where(anon_token: anon_token).each do |group|
        @groups << group unless @groups.include? group
      end
      @groups.reverse!
    end
  end

  def index
    @groups = Group.global.reverse
  end

  def show
    if @group
      # extra security
      if @requested_by_integer_id
        redirect_to show_group_path @group.unique_token
      end
      reset_page
      # solves loading error
      session[:page] = 1
      @group_shown = true
      @post = Post.new
      @proposal = Proposal.new
      build_feed
      @items = @items.first(10)
      @char_bits = char_bits @items
      # records all groups posts/motion views
      @items.each { |item| seent item }
      # records group being seen
      seent @group
    else
      redirect_to '/404'
    end
  end

  def new
    @group = Group.new
  end

  def edit
    @editing = true
  end

  def create
    @group = Group.new(group_params)
    if current_user
      @group.user_id = current_user.id
    else
      @group.anon_token = anon_token
    end
    if @group.save
      Tag.extract @group
      if @group.anon_token
        # goes to anrcho group if anon_token present
        redirect_to show_group_path(@group.unique_token)
      else
        redirect_to @group
      end
    else
      render :new
    end
  end

  def update
    if @group.update(group_params)
      Tag.extract @group
      redirect_to :back, notice: "Group updated successfully..."
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    if anrcho? or not current_user
      redirect_to my_anon_groups_path
    else
      redirect_to my_groups_path
    end
  end

  private

  def build_feed
    @items = @group.posts + @group.proposals
    @items.sort_by! { |i| i.created_at }.reverse!
    @items_size = @items.size
  end

  def anrcho_only
    unless anrcho?
      redirect_to '/404'
    end
  end

  def invited_or_anrcho
    unless invited? or anrcho?
      redirect_to invite_only_path
    end
  end

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end

  def dev_only
    redirect_to '/404' unless dev?
  end

  def secure_group
    set_group
    secure = if current_user
      current_user.id.eql? @group.user_id
    else
      anon_token.eql? @group.anon_token
    end
    # checks for model of consensus
    consensus_group = @group.social_structure.eql? 'consensus'
    # redirect to 404 unless secure
    redirect_to '/404' if consensus_group or !(secure or dev?)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    if params[:token]
      @group = Group.find_by_unique_token(params[:token])
      @group ||= Group.find_by_name params[:token]
      @group ||= Group.find_by_id(params[:token])
    elsif params[:name] and not request.bot?
      @group = Group.find_by_name(params[:name])
    else
      @group = Group.find_by_id(params[:id])
      @group ||= Group.find_by_name params[:id]
      @group ||= Group.find_by_unique_token(params[:id])
      # for redirection to the more secure path
      @requested_by_integer_id = true if @group
    end
    redirect_to '/404' unless @group or params[:id].nil?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name, :body, :image, :open, :hidden, :social_structure, :token)
  end
end
