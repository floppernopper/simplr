class NotesController < ApplicationController
  before_action :current_notes, only: [:index, :destroy, :load_more_notes, :dropdown]
  before_action :dev_only, only: [:dev_index]

  def dropdown
    #@notes = @notes.last(5).reverse
    @unseen = current_notes.unseen
    @unseen.update_all seen: true
  end

  def instant_notes
  end

  def dev_index
    @notes = Note.all.last(20).reverse
  end

  def show
    @note = Note.find_by_id params[:id]
  end

  def load_more_notes
    build_feed
    @notes = paginate @notes
    page_turning @notes
  end

  def index
    reset_page
    # solves loading error
    session[:page] = 1
    build_feed
    @notes = @notes.first(10)
    @char_bits = char_bits @notes.delete_if {|i| i.message.nil?}
  end

  private

  def build_feed
    @notes = @notes.sort_by { |i| i.created_at }.reverse
    @notes_size = @notes.size
  end

  def dev_only
    redirect_to '/404' unless dev?
  end

  def current_notes
    @notes = if current_user
      current_user.notes
    else
      Note.where(anon_token: anon_token)
    end
  end
end
