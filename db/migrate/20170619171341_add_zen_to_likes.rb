class AddZenToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :zen, :boolean
  end
end
