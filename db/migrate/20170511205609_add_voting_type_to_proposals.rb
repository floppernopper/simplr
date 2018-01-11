class AddVotingTypeToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :voting_typpe, :string
  end
end
