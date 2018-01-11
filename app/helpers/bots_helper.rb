module BotsHelper
  def bot_nick_name name
    beginning = name.first(3)
    ending = name.last(3)
    return beginning + "_" + ending
  end
end
