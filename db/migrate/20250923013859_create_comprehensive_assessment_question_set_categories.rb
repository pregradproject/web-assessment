class CreateComprehensiveAssessmentQuestionSetCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_question_set_categories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :comprehensive_assessment_question_set, null: false, foreign_key: true, type: :uuid
      t.references :comprehensive_assessment_category, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :comprehensive_assessment_question_set_categories,
              [ :comprehensive_assessment_question_set_id, :comprehensive_assessment_category_id ],
              unique: true,
              name: 'idx_ca_qset_categories_unique'
  end
end
