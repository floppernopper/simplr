class AddNoteIdToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :note_id, :integer
  end
end
