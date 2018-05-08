class AddProposalIdToPictures < ActiveRecord::Migration[5.0]
  def change
    add_column :pictures, :proposal_id, :integer
  end
end
