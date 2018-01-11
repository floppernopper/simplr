class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  before_action :invite_only, except: [:meme_war_classes]
  
  def my_games
    @games = Game.my_games current_user
  end
  
  def reset_interface
    @game = Game.find_by_unique_token session[:game_token]
  end
  
  def confirm_turn_choice
    @game = Game.find_by_unique_token params[:token]
    @turn_choice = params[:choice]
    @result = { choice: @turn_choice.to_sym }
    @other_player = @game.connections.where.not(user_id: current_user.id).last
    @other_user = @other_player.user
    @target = @other_user._class
    
    case @turn_choice
    when "attack"
      @damage = current_user._class.attack @target
      @result[:damage] = @damage
      
      if @target.health <= 0
        @result[:target_dead] = true
        @result[:target_name] = @other_user.name
      end
    when "cast"
    when "build"
    when "respawn"
      current_user._class.update health: class_health(current_user._class.game_class)
    when "skip"
    end
    
    # changes turn to other player
    @game.update current_turn_of_id: @other_player.id
    Note.notify :your_turn_in_game, @game.unique_token, @other_user, current_user
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
    @game = Game.find_by_unique_token session[:game_token]
    @_class = current_user.game_pieces.new game_class: session[:class_selection]
    @_class.health = class_health @_class.game_class
    
    notice = if @_class.save
      "Class selection confirmed."
    else
      "Error selecting class."
    end
    
    # remove choice from memory
    session.delete :class_selection
    
    redirect_to show_game_path(@game.unique_token), notice: notice
  end
  
  def challenge
    @other_user = User.find_by_unique_token params[:token]
    @game = Game.new
    
    if @game.save
      @game.connections.create user_id: @other_user.id
      @game.connections.create user_id: current_user.id
      
      # challenger user gets first turn
      @game.update current_turn_of_id: @game.connections.last.id
      
      # notify other player
      Note.notify :game_challenge, @game.unique_token, @other_user, current_user
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
  
  def class_health _class
    case _class
    when "warrior", "paladin"
      fib_num GamePiece.classes[:warrior][:health]
    when "ranger", "warlock", "rogue"
      fib_num GamePiece.classes[:ranger][:health]
    when "mage", "priest"
      fib_num GamePiece.classes[:mage][:health]
    else
      fib_num 9
    end
  end

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_game
    if params[:token]
      @game = Game.find_by_unique_token(params[:token])
      @game ||= Game.find_by_id(params[:token])
    else
      @game = Game.find_by_unique_token(params[:id])
      @game ||= Game.find_by_id(params[:id])
    end
    redirect_to '/404' unless @game
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params
    params.fetch(:game, {})
  end
end
