class LikesController < ApplicationController
  before_action :set_item
  
  def show
    @like = Like.find_by_id params[:id]
    @comments = @like.comments
  end
  
  def create
    # starts new like type
    @like = if params[:love]
      @item.loves.new
    elsif params[:whoa]
      @item.whoas.new
    else
      @item.likes.new
    end
    # assigns like type
    if params[:love]
      @like.love = true
    elsif params[:whoa]
      @like.whoa = true
    end
    if current_user
      @like.user_id = current_user.id
    else
      @like.anon_token = anon_token
    end
    if @like.save
      if (current_user and not @item.user.eql? current_user) or (anon_token and not @item.anon_token.eql? anon_token)
        Note.notify "#{@item.class.to_s.downcase}_#{@like.love ? 'love' : (@like.whoa ? 'whoa' : 'like')}".to_sym,
          (@item.is_a?(Proposal) || @item.is_a?(Vote) ? @item.unique_token : @item),
          (@item.user ? @item.user : @item.anon_token), (current_user ? current_user : anon_token)
      end
    end
  end
  
  def destroy
    like = if current_user
      @item.likes.where(user_id: current_user.id).last
    else
      @item.likes.where(anon_token: anon_token).last
    end
    like.destroy
  end
  
  private
    def set_item
      @item = if params[:post_id]
        Post.find_by_id params[:post_id]
      elsif params[:comment_id]
        Comment.find_by_id params[:comment_id]
      elsif params[:user_id]
        User.find_by_id params[:user_id]
      elsif params[:proposal_id]
        Proposal.find_by_id params[:proposal_id]
      elsif params[:vote_id]
        Vote.find_by_id params[:vote_id]
      elsif params[:like_id]
        Like.find_by_id params[:like_id]
      end
    end
end
