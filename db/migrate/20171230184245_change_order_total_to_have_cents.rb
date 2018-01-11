class ChangeOrderTotalToHaveCents < ActiveRecord::Migration[5.0]
  def change
    rename_column :orders, :total, :total_cents
  end
end
