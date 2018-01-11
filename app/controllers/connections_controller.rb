class ConnectionsController < ApplicationController
  before_action :set_item, only: [:new, :create, :update, :destroy,
    :members, :invites, :requests, :following, :followers, :steal_follower]
  before_action :invite_only, except: [:backdoor, :peace, :invite_only_message, :redeem_invite, :zen, :new, :create, :members]
  before_action :invited_or_anrcho, only: [:new, :create, :members]
  before_action :user_access, only: [:invites, :followers]
  before_action :dev_only, only: [:zen]
  
  def invite_someone
    unless current_user and (current_user.has_power? 'invite_someone' or current_user.gatekeeper)
      redirect_to '/404'
    else
      if params[:invite_token]
        @invite = Connection.find_by_unique_token params[:invite_token]
        if @invite
          @invite_link = root_url; @invite_link.slice!(-1)
          @invite_link +=redeem_invite_path(@invite.unique_token)
        end
      end
    end
  end
  
  def peace
    if current_user
      current_user.update_token
    end
    cookies.clear
    redirect_to root_url
  end
  
  def zen
    cookies.clear
    cookies[:zen] = true
    redirect_to root_url
  end
  
  # to make inviting easier in person without sending them a link
  def backdoor
    redirect_to '/404' if invited?
    # for one-use password invites
    if params[:password].present?
      @invite = Connection.where(invite_password: params[:password]).last if params[:password]
    # for initializing web server with dev at start up
    elsif (Connection.all.size + User.all.size).zero?
      @invite = Connection.create invite: true, grant_dev_access: true
    end
    if @invite and not @invite.redeemed
      redirect_to redeem_invite_path(@invite.unique_token)
    elsif params[:password].present?
      redirect_to :back
    end
  end
  
  def copy_invite_link
  end
  
  def invite_only_message
    if anrcho?
      redirect_to proposals_path
    end
    @post = Post.new un_invited: true
    @posts = Post.un_invited.last(10).reverse
    @invite_only_page = true
    @char_bits = char_bits Post.last 10
    @char_codes = char_codes Post.last 10
  end
  
  def redeem_invite
    @invite = Connection.find_by_unique_token params[:token]
    if @invite and @invite.invited_to_site?
      if !@invite.redeemed
        @invite.update redeemed: true
        if @invite.redeemed
          cookies[:grant_dev_access] = @invite.grant_dev_access
          cookies[:grant_gk_access] = @invite.grant_gk_access
          cookies.permanent[:human] = true
        end
        if @invite.forrest_only
          cookies.permanent[:forrest_only_invite_token] = @invite.unique_token
        else
          cookies.permanent[:invite_token] = @invite.unique_token
        end
      # if invite already redeemed in current browser
      elsif @invite.redeemed and invited?
        @already_redeemed = true
      end
      redirect_to new_user_path(@already_redeemed ? { already_redeemed: true } : nil)
    else
      redirect_to '/404'
    end
  end
    
  def generate_invite
    @invite = Connection.new invite: true,
      forrest_only: params[:forrest_only],
      grant_dev_access: params[:grant_dev_access],
      grant_mod_access: params[:grant_mod_access],
      grant_gk_access: params[:grant_gk_access]
    if params[:password].present?
      @invite.invite_password = params[:password]
    end
    if @invite.save
      if dev?
        redirect_to dev_panel_path(invite_token: @invite.unique_token)
      # redirects to different page if power unlocked for one-time invite and not yet used
      elsif current_user.has_power? 'invite_someone', :not_expired
        # power to invite expires after one-time-use
        current_user.has_power?('invite_someone').update expired: true
        redirect_to invite_someone_path(invite_token: @invite.unique_token)
      # gatekeepers have indefinite access to invite privilge
      elsif current_user.gatekeeper
        redirect_to invite_someone_path(invite_token: @invite.unique_token)
      else
        redirect_to root_url
      end
    else
      redirect_to :back
    end
  end

  def new
    @connection = Connection.new
  end

  # for inviting users to join a group
  def create
    if @group and @user
      invite = @group.invite_to_join @user
      Note.notify(:group_invite, nil, @user, current_user) if invite
    elsif @group
      request = current_user.request_to_join @group
      if request
        # boolean for ajax
        @requested = true
        # notifies the group creator of a users request to join the group
        Note.notify(:group_request, @group, @group.creator, current_user)
        # notifies all made members of the request to join
        for member in @group.members
          Note.notify(:group_request, @group, member.user, current_user)
        end
      end
    elsif @user
      # follows and sets boolean for ajax script
      connection = current_user.follow @user; @followed = true
      Note.notify(:user_follow, nil, @user, current_user) if connection
    end
    redirect_to :back unless @followed or @requested
  end
  
  # when group invite or request is accepted
  def update
    if @connection
      request = @connection.request
      @connection.update invite: false, request: false
      if @connection.group
        if request
          Note.notify :group_request_accepted, @connection.group, @connection.user, current_user
        end
      end
    end
    redirect_to :back
  end

  def destroy
    if @group and @user
      @group.remove @user
    elsif @group
      # removes user from group and sets boolean for ajax
      @group.remove current_user; @left_group = true
    elsif @user
      current_user.unfollow @user
      @unfollowed = true
    elsif @connection
      @connection.destroy
    end
    redirect_to :back unless @unfollowed or @left_group
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
    @following = @user.following.last(10).reverse
  end

  def followers
    @followers = @user.followers.last(10).reverse
  end
  
  def steal_follower
    @follower = User.find_by_id params[:follower_id]
    # if both users found and power has not been used yet
    if @user and @follower and current_user.has_power? 'steal_followers', :not_expired
      # finds the connection between user being followed and the follower
      @connection = @follower.connections.find_by_other_user_id @user.id
      # if connection is found and the follower is not the current_user
      if @connection and not @follower.eql? current_user
        @connection.update other_user_id: current_user.id
        current_user.has_power?('steal_followers').update expired: true
      end
    end
    redirect_to :back
  end

  private
  
  def dev_only
    unless ENV['RAILS_ENV'].eql? 'development'
      redirect_to '/404'
    end
  end
  
  def user_access
    if current_user
      unless @user.eql? current_user or dev? or \
        (action_name.eql? 'followers' and current_user.has_power? 'steal_followers', :not_expired)
        redirect_to '/404'
      end
    else
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
  
  def set_item
    @user = User.find_by_id params[:user_id]
    @group = Group.find_by_id params[:group_id]
    @connection = Connection.find_by_id params[:id] unless @user or @group
  end
end
