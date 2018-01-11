class AddHypeToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :hype, :boolean
  end
end
