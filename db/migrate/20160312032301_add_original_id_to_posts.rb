class AddOriginalIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :original_id, :integer
  end
end
