class BehavioralLearningTestAnswer < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id point answered_at created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[behavioral_learning_test behavioral_learning_question behavioral_learning_category]
  end

  belongs_to :behavioral_learning_test
  belongs_to :behavioral_learning_question
  belongs_to :behavioral_learning_category

  validates :point, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 5
  }
  validates :answered_at, presence: true
  validates :behavioral_learning_question_id, uniqueness: {
    scope: :behavioral_learning_test_id,
    message: 'can only be answered once per test'
  }

  # Validate that the category matches the question's category
  validate :category_matches_question

  scope :by_category, ->(category) { where(behavioral_learning_category: category) }
  scope :ordered, -> { order(:answered_at) }

  private

  def category_matches_question
    return unless behavioral_learning_question && behavioral_learning_category

    if behavioral_learning_question.behavioral_learning_category_id != behavioral_learning_category.id
      errors.add(:behavioral_learning_category_id, "must match the question's category")
    end
  end
end
