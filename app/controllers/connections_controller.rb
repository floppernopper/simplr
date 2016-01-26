class ConnectionsController < ApplicationController
  before_action :set_item, only: [:new, :create, :update, :destroy,
    :members, :invites, :requests, :following, :followers]

  def new
    @connection = Connection.new
  end

  def create
    if @group and @user
      invite = @group.invite_to_join @user
      Note.notify(:group_invite, nil, @user, current_user) if invite
    elsif @group
      request = current_user.request_to_join @group
      Note.notify(:group_request, @group, @group.creator, current_user) if request
    elsif @user
      connection = current_user.follow @user
      Note.notify(:user_follow, nil, @user, current_user) if connection
    end
    redirect_to :back
  end

  def update
    if @connection
      @connection.update invite: false, request: false
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
    elsif @connection
      @connection.destroy
    end
    redirect_to :back
  end

  def my_groups
    @group = Group.new
  end

  def members
    @members = @group.members
  end

  def invites
    @invites = @user.invites
  end

  def requests
    @requests = @group.requests
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
    @connection = Connection.find_by_id params[:id] unless @user or @group
  end
end