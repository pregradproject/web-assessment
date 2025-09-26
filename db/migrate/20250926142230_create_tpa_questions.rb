class CreateTpaQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :tpa_questions do |t|
      t.references :tpa_category, null: false, foreign_key: true
      t.references :tpa_question_set, null: false, foreign_key: true
      t.text :question_text, null: false, limit: 1000
      t.text :option_a, null: false, limit: 200
      t.text :option_b, null: false, limit: 200
      t.text :option_c, null: false, limit: 200
      t.text :option_d, null: false, limit: 200
      t.text :option_e, null: false, limit: 200
      t.string :correct_answer, null: false, limit: 1
      t.text :explanation
      t.integer :difficulty_level, default: 1

      t.timestamps
    end

    add_index :tpa_questions, [ :tpa_question_set_id, :tpa_category_id ]
    add_index :tpa_questions, :difficulty_level
  end
end
