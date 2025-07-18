class CreateAiKnowledgeQuestionSetCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_question_set_categories, id: :uuid do |t|
      t.uuid :ai_knowledge_question_set_id, null: false
      t.uuid :ai_knowledge_category_id, null: false
      t.integer :time_limit_secs, null: false
      t.timestamps
    end

    add_index :ai_knowledge_question_set_categories, :ai_knowledge_question_set_id
    add_index :ai_knowledge_question_set_categories, :ai_knowledge_category_id
  end
end
