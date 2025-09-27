class CreateTpaResultLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :tpa_result_levels, id: :uuid do |t|
      t.references :tpa_test, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.integer :total_score, null: false, default: 0
      t.integer :total_questions, null: false
      t.decimal :average_score, null: false, precision: 5, scale: 2
      t.string :level_label, null: false
      t.text :level_message, null: false
      t.integer :verbal_score, default: 0
      t.integer :quantitative_score, default: 0
      t.integer :analytic_score, default: 0
      t.integer :spatial_score, default: 0

      t.timestamps
    end

    add_index :tpa_result_levels, :average_score
    add_index :tpa_result_levels, :level_label
  end
end
