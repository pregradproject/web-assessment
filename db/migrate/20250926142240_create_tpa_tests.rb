class CreateTpaTests < ActiveRecord::Migration[8.0]
  def change
    create_table :tpa_tests do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :tpa_question_set, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :tpa_tests, [ :user_id, :status ]
    add_index :tpa_tests, :status
    add_index :tpa_tests, :created_at
  end
end
