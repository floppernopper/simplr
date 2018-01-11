module GamesHelper
  def your_choices
    unless you_are_dead?
      [:attack, :build, :skip]
    else
      [:respawn]
    end
  end
  
  def you_are_dead?
    current_user._class.dead?
  end
  
  def your_turn?
    if @game and @game.your_turn? current_user
      true
    end
  end
end
