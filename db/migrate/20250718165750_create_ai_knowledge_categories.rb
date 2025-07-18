class CreateAiKnowledgeCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_categories, id: :uuid do |t|
      t.string  :code, limit: 2, null: false
      t.string  :name
      t.string  :description
      t.string  :result_text
      t.timestamps
    end

    add_index :ai_knowledge_categories, :code, unique: true
  end
end
