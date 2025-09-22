class BehavioralLearningQuestion < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id body created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[behavioral_learning_category behavioral_learning_question_set]
  end

  belongs_to :behavioral_learning_question_set
  belongs_to :behavioral_learning_category
  has_many :behavioral_learning_test_answers, dependent: :destroy

  scope :by_category, ->(category) { where(behavioral_learning_category: category) }
  scope :ordered, -> { order(:created_at) }
end
