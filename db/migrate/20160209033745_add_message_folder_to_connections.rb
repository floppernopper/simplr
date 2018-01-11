class AddMessageFolderToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :message_folder, :boolean
  end
end
