class AddUnInvitedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :un_invited, :boolean
  end
end
