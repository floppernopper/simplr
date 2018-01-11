class RenameMemeWars < ActiveRecord::Migration[5.0]
  def change
    rename_column :game_pieces, :meme_war_class, :game_class
    rename_column :game_pieces, :meme_war_class_preset, :game_class_preset
  end
end
