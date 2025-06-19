class CreateVarkResultLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_result_levels, id: :uuid do |t|
      t.uuid :vark_test_id, null: false
      t.uuid :user_id, null: false
      t.integer :min_score, null: false
      t.integer :max_score, null: false
      t.integer :visual_score
      t.integer :aural_score
      t.integer :read_score
      t.integer :kinesthetic_score
      t.timestamps
    end

    add_index :vark_result_levels, :vark_test_id
    add_index :vark_result_levels, :user_id
  end
end
