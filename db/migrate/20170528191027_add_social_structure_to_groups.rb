class AddSocialStructureToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :social_structure, :string
  end
end
