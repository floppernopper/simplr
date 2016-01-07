class ConnectionsController < ApplicationController
  before_action :set_item, only: [:create, :destroy, :following, :followers]
  
  def create
    if @group and @user
      @group.invite_to_join @user
    elsif @group
      current_user.request_to_join @group
    elsif @user
      current_user.follow @user
    end
    redirect_to :back
  end
  
  def destroy
    if @group and @user
      @group.remove @user
    elsif @group
      @group.remove current_user
    elsif @user
      current_user.unfollow @user
    end
    redirect_to :back
  end
  
  def members
    @members = @group.members
  end
  
  def invites
    @group.invites
  end
  
  def requests
    @group.requests
  end
  
  def following
    @following = @user.following
  end
  
  def followers
    @followers = @user.followers
  end

  private
  
  def set_item
    @user = User.find_by_id params[:user_id]
    @group = Group.find_by_id params[:group_id]
  end
end
