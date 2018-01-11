class AddVoteIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :vote_id, :integer
  end
end
