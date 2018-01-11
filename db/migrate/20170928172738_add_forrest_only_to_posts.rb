class AddForrestOnlyToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :forrest_only, :boolean
  end
end
