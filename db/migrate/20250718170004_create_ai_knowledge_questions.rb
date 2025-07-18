class CreateAiKnowledgeQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_questions, id: :uuid do |t|
      t.uuid :ai_knowledge_question_set_id, null: false
      t.uuid :ai_knowledge_category_id, null: false
      t.text :body, null: false
      t.integer :max_weight, null: false, default: 5
      t.timestamps
    end

    add_index :ai_knowledge_questions, :ai_knowledge_question_set_id
    add_index :ai_knowledge_questions, :ai_knowledge_category_id
  end
end
