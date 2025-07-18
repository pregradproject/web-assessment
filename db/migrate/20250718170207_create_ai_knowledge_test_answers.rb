class CreateAiKnowledgeTestAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_test_answers, id: :uuid do |t|
      t.uuid :ai_knowledge_test_id, null: false
      t.uuid :ai_knowledge_question_id, null: false
      t.uuid :ai_knowledge_category_id, null: false
      t.decimal :point, precision: 4, scale: 1, null: false
      t.datetime :answered_at
      t.timestamps
    end

    add_index :ai_knowledge_test_answers, :ai_knowledge_test_id
    add_index :ai_knowledge_test_answers, :ai_knowledge_question_id
    add_index :ai_knowledge_test_answers, :ai_knowledge_category_id
  end
end
