class PagesController < ApplicationController
  before_action :set_human

  def resume
  end

  def more
    page_turning relevant_items
    build_feed_data
  end

  def scroll_to_top
  end

  def toggle_menu
    # if nav menu is already open and was opened in the last 10 seconds
    if session[:nav_menu_shown].present? and session[:nav_menu_shown_at].to_datetime > 5.second.ago
      @nav_menu_shown = true
      session[:nav_menu_shown] = ''
    else
      @nav_menu_shown = false
      session[:nav_menu_shown] = true
      session[:nav_menu_shown_at] = DateTime.current
    end
  end

  private

  def set_human
    cookies.permanent[:probably_human] = true unless current_user
  end

  def build_feed_data
    @all_items = relevant_items
    # applies to all item types
    @items = paginate @all_items
    @char_codes = char_codes @items
    @char_bits = char_bits @items
    # records being seen
    @items.each {|item| seent item}
  end

  def relevant_items
    # for anarcho
    if params[:proposals]
      @proposals = true
      return (in_dev? ? Proposal.all : Proposal.globals).sort_by { |proposal| proposal.score }
    # for social_maya
    elsif params[:posts]
      @home_shown = true
      if current_user
        if $all_items
          # already sorted, only needs sorting once
          return $all_items
        else
          # should only run if hasn't been sorted yet
          return current_user.feed # turned off out of paranoia that it's still being used
        end
      else
        return Post.all.reverse
      end
    elsif params[:preview]
      @preview_shown = true
      return Post.preview_posts
    elsif params[:group_id]
      @group_shown = true
      return Group.find_by_id(params[:group_id]).posts.reverse
    end
  end
end
