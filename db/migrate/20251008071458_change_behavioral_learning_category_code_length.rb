class ChangeBehavioralLearningCategoryCodeLength < ActiveRecord::Migration[8.0]
  def up
    change_column :behavioral_learning_categories, :code, :string, limit: 10
  end

  def down
    change_column :behavioral_learning_categories, :code, :string, limit: 1
  end
end
