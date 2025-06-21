class AddTimeLimitToVarkQuestionSet < ActiveRecord::Migration[8.0]
  def change
    add_column :vark_question_sets, :time_limit, :integer, default: 0, null: false
  end
end
