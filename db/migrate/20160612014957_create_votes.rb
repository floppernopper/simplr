class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :proposal_id
      t.integer :comment_id
      t.integer :vote_id
      t.string :unique_token
      t.string :anon_token
      t.text :body
      t.string :flip_state
      t.boolean :verified
      t.integer :proposal_version
      t.boolean :moot
      t.timestamps null: false
    end
  end
end
