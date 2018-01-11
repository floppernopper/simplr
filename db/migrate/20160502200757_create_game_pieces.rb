class CreateGamePieces < ActiveRecord::Migration
  def change
    create_table :game_pieces do |t|
      t.string :unique_token
      t.integer :user_id
      t.integer :treasure_id
      t.integer :secret_id
      t.string :name
      t.text :body
      t.string :image
      t.string :game_type
      t.string :piece_type
      t.timestamps null: false
    end
  end
end
