module GamesHelper
  def your_turn?
    if @game and @game.your_turn? current_user
      true
    end
  end
end
