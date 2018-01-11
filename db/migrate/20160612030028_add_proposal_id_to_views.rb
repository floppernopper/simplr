class AddProposalIdToViews < ActiveRecord::Migration
  def change
    add_column :views, :proposal_id, :integer
  end
end
