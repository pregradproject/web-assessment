class CreateComprehensiveAssessmentThresholdLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_threshold_levels, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :level_label, null: false
      t.text :level_message
      t.integer :threshold_min, null: false
      t.integer :threshold_max, null: false

      t.timestamps
    end

    add_index :comprehensive_assessment_threshold_levels, [ :threshold_min, :threshold_max ], unique: true
  end
end
