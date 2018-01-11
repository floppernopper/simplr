class AddVoteIdToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :vote_id, :integer
  end
end
