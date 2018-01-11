class AddCommentIdToViews < ActiveRecord::Migration
  def change
    add_column :views, :comment_id, :integer
  end
end
