class AddMemeWarClassToGamePieces < ActiveRecord::Migration[5.0]
  def change
    add_column :game_pieces, :meme_war_class, :string
    add_column :game_pieces, :level, :integer
    add_column :game_pieces, :ability, :string
    add_column :game_pieces, :active, :boolean
    
    add_column :game_pieces, :level_requirement, :integer
    add_column :game_pieces, :item_type, :string
    add_column :game_pieces, :cost, :integer
    
    add_column :game_pieces, :expires_at, :datetime
    
    add_column :games, :game_type, :string
  end
end
