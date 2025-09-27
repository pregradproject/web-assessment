class CreateTpaAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :tpa_answers, id: :uuid do |t|
      t.references :tpa_test, null: false, foreign_key: true, type: :uuid
      t.references :tpa_question, null: false, foreign_key: true, type: :uuid
      t.string :selected_option, null: false, limit: 1
      t.boolean :is_correct, null: false
      t.datetime :answered_at, null: false

      t.timestamps
    end

    add_index :tpa_answers, [ :tpa_test_id, :tpa_question_id ], unique: true
    add_index :tpa_answers, :answered_at
  end
end
