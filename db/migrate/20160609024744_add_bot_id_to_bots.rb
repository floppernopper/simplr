class AddBotIdToBots < ActiveRecord::Migration
  def change
    add_column :bots, :bot_id, :integer
  end
end
