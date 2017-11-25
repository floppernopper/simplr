class AddGameIdToGamePieces < ActiveRecord::Migration[5.0]
  def change
    add_column :game_pieces, :game_id, :integer
  end
end
