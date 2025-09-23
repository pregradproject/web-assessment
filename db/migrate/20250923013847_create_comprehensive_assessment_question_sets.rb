class CreateComprehensiveAssessmentQuestionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_question_sets, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer :version, null: false
      t.string :name, null: false
      t.boolean :active, default: false, null: false
      t.integer :time_limit, default: 0, null: false

      t.timestamps
    end

    add_index :comprehensive_assessment_question_sets, :version, unique: true
    add_index :comprehensive_assessment_question_sets, :active
  end
end
