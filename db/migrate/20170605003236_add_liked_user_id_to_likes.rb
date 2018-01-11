class AddLikedUserIdToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :liked_user_id, :integer
  end
end
