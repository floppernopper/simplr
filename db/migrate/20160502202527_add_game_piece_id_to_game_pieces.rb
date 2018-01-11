class AddGamePieceIdToGamePieces < ActiveRecord::Migration
  def change
    add_column :game_pieces, :game_piece_id, :integer
  end
end
