class AddHealthToGamePieces < ActiveRecord::Migration[5.0]
  def change
    add_column :game_pieces, :health, :float
    add_column :game_pieces, :stamina, :float
    add_column :game_pieces, :mana, :float
  end
end
