class CreateBehavioralLearningTestAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_test_answers, id: :uuid do |t|
      t.references :behavioral_learning_test, null: false, foreign_key: true, type: :uuid
      t.references :behavioral_learning_question, null: false, foreign_key: true, type: :uuid
      t.references :behavioral_learning_category, null: false, foreign_key: true, type: :uuid
      t.integer :point, null: false
      t.timestamp :answered_at, null: false

      t.timestamps
    end

    add_index :behavioral_learning_test_answers,
              [ :behavioral_learning_test_id, :behavioral_learning_question_id ],
              unique: true,
              name: 'index_bl_test_answers_on_test_and_question'
    add_check_constraint :behavioral_learning_test_answers, 'point >= 1 AND point <= 5', name: 'bl_point_range_check'
  end
end
