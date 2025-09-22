class CreateBehavioralLearningThresholdLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_threshold_levels, id: :uuid do |t|
      t.string :label, null: false
      t.text :message, null: false
      t.decimal :min_threshold, precision: 5, scale: 2, null: false
      t.decimal :max_threshold, precision: 5, scale: 2, null: false
      t.integer :priority, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :behavioral_learning_threshold_levels, :priority, unique: true
    add_index :behavioral_learning_threshold_levels, :active
  end
end
