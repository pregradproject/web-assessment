class CreateBehavioralLearningQuestionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_question_sets, id: :uuid do |t|
      t.string :name, null: false
      t.string :version, null: false
      t.boolean :active, default: false
      t.integer :time_limit, default: 1800

      t.timestamps
    end

    add_index :behavioral_learning_question_sets, :active
  end
end
