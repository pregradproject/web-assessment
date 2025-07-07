class ChangeVarkResultLevelsScoresToDecimal < ActiveRecord::Migration[8.0]
  def up
    change_column :vark_result_levels, :visual_score, :decimal, precision: 6, scale: 1
    change_column :vark_result_levels, :aural_score, :decimal, precision: 6, scale: 1
    change_column :vark_result_levels, :read_score, :decimal, precision: 6, scale: 1
    change_column :vark_result_levels, :kinesthetic_score, :decimal, precision: 6, scale: 1
    change_column :vark_result_levels, :min_score, :decimal, precision: 6, scale: 1
    change_column :vark_result_levels, :max_score, :decimal, precision: 6, scale: 1
  end

  def down
    change_column :vark_result_levels, :visual_score, :integer
    change_column :vark_result_levels, :aural_score, :integer
    change_column :vark_result_levels, :read_score, :integer
    change_column :vark_result_levels, :kinesthetic_score, :integer
    change_column :vark_result_levels, :min_score, :integer
    change_column :vark_result_levels, :max_score, :integer
  end
end
