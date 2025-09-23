class CreateComprehensiveAssessmentResultLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_result_levels, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :comprehensive_assessment_test, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :total_score
      t.integer :total_questions
      t.decimal :average_score, precision: 5, scale: 2
      t.string :level_label
      t.text :level_message
      t.integer :threshold_min
      t.integer :threshold_max

      t.timestamps
    end

    add_index :comprehensive_assessment_result_levels, :comprehensive_assessment_test_id,
              unique: true, name: 'idx_ca_result_levels_test_id_unique'
  end
end
