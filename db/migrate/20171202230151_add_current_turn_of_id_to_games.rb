class AddCurrentTurnOfIdToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :current_turn_of_id, :integer
  end
end
