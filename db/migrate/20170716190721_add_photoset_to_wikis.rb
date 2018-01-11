class AddPhotosetToWikis < ActiveRecord::Migration[5.0]
  def change
    add_column :wikis, :photoset, :boolean
  end
end
