class CreateBehavioralLearningQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_questions, id: :uuid do |t|
      t.references :behavioral_learning_question_set, null: false, foreign_key: true, type: :uuid
      t.references :behavioral_learning_category, null: false, foreign_key: true, type: :uuid
      t.text :body, null: false

      t.timestamps
    end
  end
end
