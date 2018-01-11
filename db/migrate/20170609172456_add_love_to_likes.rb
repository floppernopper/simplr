class AddLoveToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :love, :boolean
    add_column :likes, :whoa, :boolean
  end
end
