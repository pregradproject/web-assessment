class ChangeVarkTestAnswersPointToDecimal < ActiveRecord::Migration[8.0]
  def up
    change_column :vark_test_answers, :point, :decimal, precision: 4, scale: 1
  end

  def down
    change_column :vark_test_answers, :point, :integer
  end
end
