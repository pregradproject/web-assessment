class CreateVarkTestAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_test_answers, id: :uuid do |t|
      t.uuid :vark_test_id, null: false
      t.uuid :vark_question_id, null: false
      t.uuid :vark_category_id, null: false
      t.integer :point, null: false
      t.datetime :answered_at
      t.timestamps
    end

    add_index :vark_test_answers, :vark_test_id
    add_index :vark_test_answers, :vark_question_id
    add_index :vark_test_answers, :vark_category_id
  end
end
