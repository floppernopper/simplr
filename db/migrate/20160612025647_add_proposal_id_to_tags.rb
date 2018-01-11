class AddProposalIdToTags < ActiveRecord::Migration
  def change
    add_column :tags, :proposal_id, :integer
  end
end
