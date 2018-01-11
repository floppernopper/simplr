class AddRedeemedToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :redeemed, :boolean
  end
end
