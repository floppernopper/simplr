class AddLikeIdToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :like_id, :integer
  end
end
