class AddPhotosetToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :photoset, :boolean
  end
end
