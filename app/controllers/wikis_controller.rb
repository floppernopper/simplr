class WikisController < ApplicationController
  before_action :set_wiki, only: [:show, :edit, :update, :destroy, :history]
  before_action :secure_wiki, only: [:new, :edit, :create, :update, :destroy]
  
  def add_image
  end
  
  def index
    @wiki = Wiki.first
    unless @wiki
      @wiki = Wiki.new
    end
    if @wiki.versions.present?
      @wiki = @wiki.versions.last
    end
  end
  
  def new
    @wiki = Wiki.new
  end
  
  def show
  end
  
  def edit
  end
  
  def create
    @wiki = Wiki.new(wiki_params)
    @wiki.user_id = current_user.id
    # sets as photoset for validation
    if params[:pictures]
      @wiki.photoset = true
    end
    if @wiki.save
      if params[:pictures]
        # builds photoset for wiki
        params[:pictures][:image].each do |image|
          @wiki.pictures.create image: image
        end
      end
      redirect_to @wiki
    else
      redirect_to :back
    end
  end
  
  def update
    if @wiki.update(wiki_params)
      if params[:pictures]
        params[:pictures][:image].each do |image|
          @wiki.pictures.create image: image
        end
      end
      redirect_to wiki_path @wiki
    else
      render :edit
    end
  end
  
  def destroy
  end
  
  def history
    @versions = @wiki.versions
  end
  
  private
  
  def secure_wiki
    unless god?
      redirect_to '/404'
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_wiki
    @wiki = Wiki.find_by_id(params[:id])
    redirect_to '/404' unless @wiki
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wiki_params
    params.require(:wiki).permit(:user_id, :title, :body, pictures_attributes: [:id, :wiki_id, :image])
  end
end
