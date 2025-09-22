class CreateBehavioralLearningTests < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_tests, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :behavioral_learning_question_set, null: false, foreign_key: true, type: :uuid
      t.integer :status, default: 0
      t.timestamp :started_at
      t.timestamp :completed_at

      t.timestamps
    end

    add_index :behavioral_learning_tests, [ :user_id, :created_at ]
    add_index :behavioral_learning_tests, :status
  end
end
