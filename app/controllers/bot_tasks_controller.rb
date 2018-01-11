class BotTasksController < ApplicationController
  # adds task field to bot form
  def add_task
    session[:task_field] = session[:task_field].to_i + 1
  end
end
