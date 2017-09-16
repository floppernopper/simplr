class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :secure_group, only: [:edit, :update, :destroy]
  before_action :dev_only, only: [:index]
  before_action :invite_only, except: [:new, :create, :update, :show, :edit, :my_anon_groups]
  before_action :invited_or_anrcho, only: [:new, :create, :show]
  before_action :anrcho_only, only: [:my_anon_groups]
  
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
      @group_shown = true
      @post = Post.new
      @proposal = Proposal.new
      @items = (@group.posts + @group.proposals).sort_by { |i| i.created_at }.last(10).reverse
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
      redirect_to @group
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to my_groups_path }
    end
  end

  private
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
      redirect_to '/404' unless secure or dev?
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find_by_id(params[:id])
      # sets group with token for anrcho groups
      @group ||= Group.find_by_unique_token(params[:token])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :body, :image, :open, :hidden, :social_structure)
    end
end
