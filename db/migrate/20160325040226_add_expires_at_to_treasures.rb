class AddExpiresAtToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :expires_at, :datetime
  end
end
