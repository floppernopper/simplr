module BotTasksHelper
  def bot_task_type_options
    options = [["Choose a task type", nil]]
    BotTask.task_types.each do |key, val|
      options << [val, key.to_s]
    end
    return options
  end
end
