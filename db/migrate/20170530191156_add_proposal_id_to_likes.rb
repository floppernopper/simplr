class AddProposalIdToLikes < ActiveRecord::Migration[5.0]
  def change
    add_column :likes, :proposal_id, :integer
  end
end
