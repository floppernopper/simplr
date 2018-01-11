class AddSecretIdToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :secret_id, :integer
  end
end
