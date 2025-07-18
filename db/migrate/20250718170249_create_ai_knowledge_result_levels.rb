class CreateAiKnowledgeResultLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :ai_knowledge_result_levels, id: :uuid do |t|
      t.uuid :ai_knowledge_test_id, null: false
      t.uuid :user_id, null: false
      t.decimal :min_score, precision: 6, scale: 1, null: false
      t.decimal :max_score, precision: 6, scale: 1, null: false
      t.decimal :performance_expectancy_score, precision: 6, scale: 1
      t.decimal :effort_expectancy_score, precision: 6, scale: 1
      t.decimal :social_influence_score, precision: 6, scale: 1
      t.decimal :facilitating_conditions_score, precision: 6, scale: 1
      t.decimal :hedonic_motivation_score, precision: 6, scale: 1
      t.decimal :price_value_score, precision: 6, scale: 1
      t.decimal :habit_score, precision: 6, scale: 1
      t.decimal :behavioral_intention_score, precision: 6, scale: 1
      t.timestamps
    end

    add_index :ai_knowledge_result_levels, :ai_knowledge_test_id
    add_index :ai_knowledge_result_levels, :user_id
  end
end
