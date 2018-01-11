class VotingTypeTypoFix < ActiveRecord::Migration[5.0]
  def change
	rename_column :proposals, :voting_typpe, :voting_type
  end
end
