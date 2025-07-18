class CreateAiKnowledgeTests < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_tests, id: :uuid do |t|
      t.uuid      :user_id, null: false
      t.uuid      :ai_knowledge_question_set_id, null: false
      t.datetime  :started_at
      t.datetime  :completed_at
      t.integer   :status, default: 0, null: false
      t.timestamps
    end

    add_index :ai_knowledge_tests, :user_id
    add_index :ai_knowledge_tests, :ai_knowledge_question_set_id
  end
end
