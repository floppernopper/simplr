class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  before_action :invite_only, except: [:meme_war_classes]
  
  def meme_war_classes
  end
  
  def class_select
    @class_selection = params[:class_selection]
    session[:class_selection] = @class_selection
  end
  
  def confirm_class_selection
    @user = current_user.update meme_war_class: session[:class_selection]
    redirect_to :back, notice: (@user ? "Class selection confirmed." : "Error selecting class.")
  end
  
  def challenge
    @user = User.find_by_unique_token params[:token]
    @game = Game.new
    
    if @game.save
      @game.connections.create user_id: @user.id
      @game.connections.create user_id: current_user.id
    end
    
    if @game and @game.players.size > 1
      redirect_to @game
    else
      redirect_to :back, notice: "Game could not be created. Error."
    end
  end

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params
    params.fetch(:game, {})
  end
end
