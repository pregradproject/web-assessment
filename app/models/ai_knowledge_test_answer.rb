class AiKnowledgeTestAnswer < ApplicationRecord
  belongs_to :ai_knowledge_test
  belongs_to :ai_knowledge_question
  belongs_to :ai_knowledge_category

  validates :point, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: :max_allowed_weight
  }
  validates :answered_at, presence: true
  validates :ai_knowledge_question_id, uniqueness: {
    scope: :ai_knowledge_test_id,
    message: 'can only be answered once per test'
  }

  # Validate that the category matches the question's category
  validate :category_matches_question

  scope :by_category, ->(category) { where(ai_knowledge_category: category) }
  scope :ordered, -> { order(:answered_at) }

  private

  def max_allowed_weight
    ai_knowledge_question&.max_weight || 5
  end

  def category_matches_question
    return unless ai_knowledge_question && ai_knowledge_category

    if ai_knowledge_question.ai_knowledge_category_id != ai_knowledge_category.id
      errors.add(:ai_knowledge_category_id, "must match the question's category")
    end
  end
end