class BehavioralLearningQuestionSetCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id active created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[behavioral_learning_category behavioral_learning_question_set]
  end

  belongs_to :behavioral_learning_question_set
  belongs_to :behavioral_learning_category
end
