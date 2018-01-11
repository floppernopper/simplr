class AddAnonTokenToTreasures < ActiveRecord::Migration
  def change
    add_column :treasures, :anon_token, :string
  end
end
