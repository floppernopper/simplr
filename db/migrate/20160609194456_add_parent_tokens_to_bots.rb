class AddParentTokensToBots < ActiveRecord::Migration
  def change
    add_column :bots, :parent_tokens, :string
  end
end
