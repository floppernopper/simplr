class AddScoreCountToViews < ActiveRecord::Migration[5.0]
  def change
    add_column :views, :score_count, :integer
  end
end
