class AddMessageIdToViews < ActiveRecord::Migration
  def change
    add_column :views, :message_id, :integer
  end
end
