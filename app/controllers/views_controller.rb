class ViewsController < ApplicationController
  before_action :god_only, only: [:user_index, :index, :show]

  def create
    if current_user and not in_dev?
      @user = current_user
      @click = View.new click: true,
        user_id: @user.id, ip_address: request.remote_ip
      for i in [:x_pos, :y_pos, :screen_width, :screen_height, :avail_screen_width, :avail_screen_height,
        :device_pixel_ratio, :current_url, :controller_name, :action_name]
        @click.write_attribute(i, params[i])
      end
      if @click.save
        true
      end
    end
  end

  def show
    @view = View.find_by_id params[:id]
  end

  def user_index
    @user = User.find_by_unique_token params[:token]
    @unique_views = [] # unique by locale
    for view in @user.views.reverse
      @unique_views << view unless @unique_views.any? { |v| v.locale.eql? view.locale }
    end
    @views = @unique_views.sort_by { |v| v.created_at }.reverse
    get_most_viewed_locale
  end

  def click_index
    @user = User.find_by_unique_token params[:token]
    @clicks = @user.views.clicks.reverse
  end

  def index
    @ip = params[:ip]
    @views = if @ip
      View.all.by_user.where(ip_address: @ip)
    else
      View.all.unique_views
    end
    @views = @views.sort_by { |v| v.created_at }.reverse
  end

  private

  def get_most_viewed_locale
    # this first should be last view created
    @most_viewed = @views.first
    a = @user.views.select { |i| i.locale.eql? @most_viewed.locale }.size
    # loops through all views by user until most viewed from locale is found
    for v in @views.reverse # reverse to lead to first/last created
      b = @user.views.select { |i| i.locale.eql? v.locale }.size
      if a < b
        @most_viewed = v
        a = b
      end
    end
    @view_count = a
  end

  def god_only
    redirect_to '/404' unless god?
  end
end
