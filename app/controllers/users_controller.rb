class UsersController < ApplicationController
  before_action :set_user, only: [:show, :kristin, :edit, :update, :update_password, :destroy, :load_more_posts]
  before_action :secure_user, only: [:edit, :update, :destroy]
  before_action :dev_only, only: [:index]
  before_action :invite_only
  
  def load_more_posts
    build_feed
    page_turning @posts
  end
  
  def geolocation
  end
  
  def hide_featured_users
    cookies.permanent[:hide_featured_users] = true
  end
  
  def new
    unless current_user
      # to ignore infinite scroll
      @preview_items = true
      @user = User.new
      # gets preview items for invitee
      @items = Post.preview_posts.last(10).reverse
      # records user viewing posts
      @items.each {|item| seent item}
      # records current time for last visit
      record_last_visit
    end
  end
  
  def create
    @user = User.new(user_params)
    # access rights from invite
    grant_access_rights
    if @user.save
      if params[:remember_me]
        cookies.permanent[:auth_token] = @user.auth_token
      else
        cookies[:auth_token] = @user.auth_token
      end
      cookies.permanent[:logged_in_before] = true
      
      # automatically follows website creator at sign up so feed is full
      connection = current_user.follow User.first if current_user
      Note.notify(:user_follow, nil, User.first, current_user) if connection
      
      # website creator automatically follows new user back
      connection = User.first.follow current_user if current_user
      Note.notify(:user_follow, nil, current_user, User.first) if connection
      
      # returns to home page, main feed
      redirect_to root_url
    else
      redirect_to :back
    end
  end

  def index
    @admin_user_index = true
    # creates array of active users and sorts by date last active
    active_users = []; User.where.not(last_active_at: nil).each { |user| active_users << user }
    active_users.sort_by! { |user| user.last_active_at }.reverse!
    # creates array of inactive users and just sorts by time of creation
    inactive_users = []; User.where(last_active_at: nil).each { |user| inactive_users << user }
    inactive_users.sort!.reverse!
    # adds both arrays together for finale
    @users = active_users + inactive_users
  end
  
  def kristin
    if true # That it always be that true is true is true so that Kristin may be Kristin
      @kristin = User.find_by_id 34 # most direct and sure fire way to find Kristin
      @kristin ||= User.find_by_name "Kristin" # didn't find Kristin with most forward approach... Try saying her name?
      @kristin ||= User.find_by_body \
        "Let me be that I am and seek not to alter me" # From a comedy by Shakespeare, Much Ado About Nothing
      if @kristin # then you totally found her
        @user = @kristin # you totally did it
        show_user_thingy_to_run 
      end
    end
  end

  def show
    if @user
      show_user_thingy_to_run
    end
    if @user and (@user.id.eql? 34 or @user.name.eql? "Kristin" \
      or @user.body.eql? "Let me be that I am and seek not to alter me")
      redirect_to kristin_path
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      Tag.extract @user
      redirect_to show_user_path(@user.unique_token), notice: "Profile/account updated successfully."
    else
      redirect_to :back, notice: "Unable to update profile/account... Error."
    end
  end
  
  def update_password
    @auth_user = User.authenticate(current_user.name, params[:old_password])
    if @auth_user or dev?
      @user.password = user_params[:password]
      @user.encrypt_password
      @notice = if @user.save
        "Password updated successfully."
      else
        "Password update failed... Error."
      end
    end
    redirect_to :back, notice: @notice
  end

  def destroy
    @user.destroy unless @user.dev or @user.god
    respond_to do |format|
      format.html { redirect_to users_url }
    end
  end

  private
  
  def build_feed
    all_user_posts
    @posts = paginate @posts
  end

  def show_user_thingy_to_run
    reset_page
    # solves loading error
    session[:page] = 1
    @post = Post.new
    all_user_posts # gets posts by users, sorts them
    @posts = @posts.first(10)
    @char_bits = char_bits @posts
    @user_shown = true
    # records being seen
    seent @user
  end
  
  def all_user_posts
    @posts = @user.posts + @user.proposals.globals.main
    @posts.sort_by! { |p| p.created_at }.reverse!
    @posts_size = @posts.size
  end
  
  def grant_access_rights
    # grants dev powers sent with invite
    if cookies[:grant_dev_access]
      # deletes to prevent creation of multiple devs
      cookies.delete(:grant_dev_access)
      @user.dev = true
    end
    # grants power of gatekeeper
    if cookies[:grant_gk_access]
      cookies.delete(:grant_gk_access)
      @user.gatekeeper = true
    end
  end
  
  def invite_only
    token_good = User.find_by_unique_token @user.unique_token if @user
    unless invited?
      redirect_to invite_only_path unless token_good
    end
  end
  
  def dev_only
    redirect_to '/404' unless dev?
  end
  
  def secure_user
    set_user; redirect_to '/404' unless current_user.eql? @user or dev?
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    if params[:token]
      @user = User.find_by_unique_token params[:token]
      @user ||= User.find_by_name params[:token]
      @user ||= User.find_by_id params[:token]
    else
      @user = User.find_by_unique_token params[:id]
      @user ||= User.find_by_name params[:id]
      @user ||= User.find_by_id params[:id]
    end
    redirect_to '/404' unless @user or params[:id].nil?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :image, :body, :title, :password, :password_confirmation)
  end
end
