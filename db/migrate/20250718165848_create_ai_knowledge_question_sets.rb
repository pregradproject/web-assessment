class CreateAiKnowledgeQuestionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_question_sets, id: :uuid do |t|
      t.integer :version, null: false
      t.string  :name
      t.boolean :active, default: true, null: false
      t.timestamps
    end
  end
end
