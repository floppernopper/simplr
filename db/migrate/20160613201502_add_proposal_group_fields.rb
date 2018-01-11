class AddProposalGroupFields < ActiveRecord::Migration
  def change
    add_column :groups, :passphrase, :string
    add_column :groups, :pass_protected, :boolean
    add_column :groups, :ratification_threshold, :integer
    add_column :groups, :view_limit, :integer
  end
end
