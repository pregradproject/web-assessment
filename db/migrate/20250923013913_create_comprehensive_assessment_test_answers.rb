class CreateComprehensiveAssessmentTestAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_test_answers, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :comprehensive_assessment_test, null: false, foreign_key: true, type: :uuid
      t.references :comprehensive_assessment_question, null: false, foreign_key: true, type: :uuid
      t.references :comprehensive_assessment_category, null: false, foreign_key: true, type: :uuid
      t.integer :point, null: false
      t.datetime :answered_at, null: false

      t.timestamps
    end

    add_index :comprehensive_assessment_test_answers,
              [ :comprehensive_assessment_test_id, :comprehensive_assessment_question_id ],
              unique: true,
              name: 'idx_ca_test_answers_unique'
  end
end
