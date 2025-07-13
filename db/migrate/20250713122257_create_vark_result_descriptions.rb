class CreateVarkResultDescriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_result_descriptions, id: :uuid do |t|
      t.string :combination_pattern, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.text :characteristics
      t.text :study_recommendations
      t.text :strengths
      t.text :potential_challenges
      t.text :career_suggestions
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :vark_result_descriptions, :combination_pattern, unique: true
  end
end
