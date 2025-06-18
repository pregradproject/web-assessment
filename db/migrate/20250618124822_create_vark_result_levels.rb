class CreateVarkResultLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_result_levels do |t|
      t.uuid :question_set_id, null: false
      t.uuid :category_id, null: false
      t.integer :min_score, null: false
      t.integer :max_score, null: false
      t.integer :visual_score
      t.integer :aural_score
      t.integer :read_score
      t.integer :kinesthetic_score
      t.timestamps
    end

    add_index :vark_result_levels, :question_set_id
    add_index :vark_result_levels, :category_id
  end
end
