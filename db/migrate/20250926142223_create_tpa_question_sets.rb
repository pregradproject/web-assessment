class CreateTpaQuestionSets < ActiveRecord::Migration[8.0]
  def change
    create_table :tpa_question_sets, id: :uuid do |t|
      t.string :name, null: false, limit: 100
      t.string :version, null: false
      t.boolean :active, null: false, default: false
      t.integer :time_limit, null: false, default: 3600

      t.timestamps
    end

    add_index :tpa_question_sets, :active
    add_index :tpa_question_sets, [ :name, :version ], unique: true
  end
end
