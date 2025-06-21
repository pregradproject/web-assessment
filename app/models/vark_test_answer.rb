class VarkTestAnswer < ApplicationRecord
  belongs_to :vark_test
  belongs_to :vark_question
  belongs_to :vark_category

  validates :point, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: :max_allowed_weight
  }
  validates :answered_at, presence: true
  validates :vark_question_id, uniqueness: {
    scope: :vark_test_id,
    message: 'can only be answered once per test'
  }

  # Validate that the category matches the question's category
  validate :category_matches_question

  scope :by_category, ->(category) { where(vark_category: category) }
  scope :ordered, -> { order(:answered_at) }

  private

  def max_allowed_weight
    vark_question&.max_weight || 5
  end

  def category_matches_question
    return unless vark_question && vark_category

    if vark_question.vark_category_id != vark_category.id
      errors.add(:vark_category_id, "must match the question's category")
    end
  end
end
