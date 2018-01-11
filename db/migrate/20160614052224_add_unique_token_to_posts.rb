class AddUniqueTokenToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :unique_token, :string
  end
end
