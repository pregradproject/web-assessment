class CreateBehavioralLearningResultLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_result_levels, id: :uuid do |t|
      t.references :behavioral_learning_test, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.integer :total_score, null: false
      t.integer :total_questions, null: false
      t.decimal :average_score, precision: 5, scale: 2, null: false
      t.string :level_label, null: false
      t.text :level_message, null: false
      t.decimal :threshold_min, precision: 5, scale: 2, null: false
      t.decimal :threshold_max, precision: 5, scale: 2, null: false

      t.timestamps
    end
  end
end
