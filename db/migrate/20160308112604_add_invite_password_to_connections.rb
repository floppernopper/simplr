class AddInvitePasswordToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :invite_password, :string
  end
end
