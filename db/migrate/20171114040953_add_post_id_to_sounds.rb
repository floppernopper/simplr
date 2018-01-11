class AddPostIdToSounds < ActiveRecord::Migration[5.0]
  def change
    add_column :sounds, :post_id, :integer
  end
end
