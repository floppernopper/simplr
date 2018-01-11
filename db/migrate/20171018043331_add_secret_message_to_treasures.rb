class AddSecretMessageToTreasures < ActiveRecord::Migration[5.0]
  def change
    add_column :treasures, :secret_message, :string
  end
end
