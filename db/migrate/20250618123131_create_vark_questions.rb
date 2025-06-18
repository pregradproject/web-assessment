class CreateVarkQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_questions, id: :uuid do |t|
      t.uuid :vark_question_set_id, null: false
      t.uuid :vark_category_id, null: false
      t.text :body, null: false
      t.timestamps
    end

    add_index :vark_questions, :vark_question_set_id
    add_index :vark_questions, :vark_category_id
  end
end
