class AddGatekeeperToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gatekeeper, :boolean
  end
end
