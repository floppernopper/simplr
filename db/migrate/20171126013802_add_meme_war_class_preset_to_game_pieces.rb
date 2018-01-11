class AddMemeWarClassPresetToGamePieces < ActiveRecord::Migration[5.0]
  def change
    add_column :game_pieces, :meme_war_class_preset, :boolean
  end
end
