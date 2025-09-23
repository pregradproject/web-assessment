class CreateComprehensiveAssessmentTests < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_tests, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :comprehensive_assessment_question_set, null: false, foreign_key: true, type: :uuid
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :comprehensive_assessment_tests, :status
    add_index :comprehensive_assessment_tests, :created_at
  end
end
