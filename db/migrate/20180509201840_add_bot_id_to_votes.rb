class AddBotIdToVotes < ActiveRecord::Migration[5.0]
  def change
    add_column :votes, :bot_id, :integer
  end
end
