class CreateVarkQuestionSetCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_question_set_categories, id: :uuid do |t|
      t.uuid :vark_question_set_id, null: false
      t.uuid :vark_category_id, null: false
      t.integer :time_limit_secs, null: false
      t.timestamps
    end

    add_index :vark_question_set_categories, :vark_question_set_id
    add_index :vark_question_set_categories, :vark_category_id
  end
end
