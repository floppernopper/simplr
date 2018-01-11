class AddVoteIdToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :vote_id, :integer
    add_column :likes, :like_id, :integer
  end
end
