class AddFeaturedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :featured, :boolean
  end
end
