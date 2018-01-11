class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.string :unique_token
      t.string :anon_token
      t.string :group_token
      t.integer :group_id
      t.integer :proposal_id
      t.string :title
      t.text :body
      t.string :image
      t.string :action
      t.string :revised_action
      t.boolean :ratified
      t.boolean :requires_revision
      t.boolean :revised
      t.integer :version
      t.integer :ratification_point
      t.timestamps null: false
    end
  end
end
