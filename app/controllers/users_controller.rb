class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :secure_user, only: [:edit, :update, :destroy]
  before_action :dev_only, only: [:index]
  before_action :invite_only
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    grant_dev_access
    if @user.save
      if params[:remember_me]
        cookies.permanent[:auth_token] = @user.auth_token
      else
        cookies[:auth_token] = @user.auth_token
      end
      cookies.permanent[:logged_in_before] = true
      redirect_to root_url
    else
      redirect_to :back, notice: "This username may already be taken."
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all.reverse
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if @user
      @post = Post.new
      @posts = @user.posts.last(10).reverse
      @user_shown = true
    end
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        Tag.extract @user
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def grant_dev_access
      # grants dev powers sent with invite
      if cookies[:grant_dev_access]
        cookies.delete(:grant_dev_access)
        @user.dev = true
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
    
    def secure_user
      set_user; redirect_to '/404' unless current_user.eql? @user or dev?
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :image, :body, :password, :password_confirmation)
    end
end
