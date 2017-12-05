class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  before_action :invite_only, except: [:meme_war_classes]
  
  def confirm_turn_choice
    @game = Game.find_by_unique_token params[:token]
    @turn_choice = params[:choice]
    
    case @turn_choice
    when "attack"
      @target = @game.connections.where.not(user_id: current_user.id).last.user._class
      @damage = current_user._class.attack @target
    end
  end
  
  def select_turn_choice
    @game = Game.find_by_unique_token session[:game_token]
    @turn_choice = params[:choice]
  end
  
  def meme_war_classes
  end
  
  def class_select
    @class_selection = params[:class_selection]
    session[:class_selection] = @class_selection
  end
  
  def confirm_class_selection
    @meme_war_class = current_user.game_pieces.new meme_war_class: session[:class_selection]
    @meme_war_class.health = case @meme_war_class.meme_war_class
    when "warrior"
      fib_num 12
    when "ranger", "mage"
      fib_num 11
    end
    
    # remove choice from memory
    session.delete :class_selection
    
    notice = if @meme_war_class.save
      "Class selection confirmed."
    else
      "Error selecting class."
    end
    redirect_to :back, notice: notice
  end
  
  def challenge
    @user = User.find_by_unique_token params[:token]
    @game = Game.new
    
    if @game.save
      @game.connections.create user_id: @user.id
      @game.connections.create user_id: current_user.id
      
      # challenger user gets first turn
      @game.update current_turn_of_id: @game.connections.last.id
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
    session[:game_token] = @game.unique_token
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
