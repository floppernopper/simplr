class BotsController < ApplicationController
  before_action :invite_only
  before_action :secure_bots
  before_action :grow_bots, only: [:my_bots, :show]
  
  def destroy_all
    Bot.destroy_all
    redirect_to dev_panel_path
  end
  
  def my_bots
    @user = User.find_by_id params[:id]
    @bots = Bot.where(user_id: @user.id).reverse if @user
  end
  
  def index
    @bots = Bot.all.reverse
  end
  
  def show
    @bot = Bot.find_by_id params[:id]
    @tasks = @bot.bot_tasks
  end
  
  def create
    @bot = Bot.new
    @bot.name = params[:bot_name]
    @bot.body = params[:bot_body]
    @bot.user_id = current_user.id
    if @bot.save
      params.each do |key, val|
        if key.include? "bot_task_"
          task = @bot.bot_tasks.new name: val
          # saves if there aren't any like tasks already assigned to bot
          task.save unless @bot.bot_tasks.find_by_name val
        end
      end
      redirect_to my_bots_path(current_user)
    else
      redirect_to :back
    end
  end
  
  private
    def grow_bots
      Bot.manifest_bots [:grow], { page: request.original_url }
    end
    
    def secure_bots
      redirect_to '/404' unless dev? or current_user.has_power?('create_bots')
    end
    
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
end
