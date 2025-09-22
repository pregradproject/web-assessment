class CreateBehavioralLearningCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :behavioral_learning_categories, id: :uuid do |t|
      t.string :code, limit: 1, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :behavioral_learning_categories, :code, unique: true
  end
end
