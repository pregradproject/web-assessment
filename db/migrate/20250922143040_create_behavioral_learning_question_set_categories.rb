class CreateBehavioralLearningQuestionSetCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_question_set_categories, id: :uuid do |t|
      t.references :behavioral_learning_question_set, null: false, foreign_key: true, type: :uuid
      t.references :behavioral_learning_category, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :behavioral_learning_question_set_categories,
              [ :behavioral_learning_question_set_id, :behavioral_learning_category_id ],
              unique: true,
              name: 'index_bl_question_set_categories_on_set_and_category'
  end
end
