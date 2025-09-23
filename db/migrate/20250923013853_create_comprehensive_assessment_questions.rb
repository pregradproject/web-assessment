class CreateComprehensiveAssessmentQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_questions, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.text :body, null: false
      t.references :comprehensive_assessment_question_set, null: false, foreign_key: true, type: :uuid
      t.references :comprehensive_assessment_category, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :comprehensive_assessment_questions, [ :comprehensive_assessment_question_set_id, :comprehensive_assessment_category_id ],
              name: 'idx_ca_questions_on_set_and_category'
  end
end
