class ComprehensiveAssessmentTestAnswer < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id point answered_at created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[comprehensive_assessment_test comprehensive_assessment_question comprehensive_assessment_category]
  end

  belongs_to :comprehensive_assessment_test
  belongs_to :comprehensive_assessment_question
  belongs_to :comprehensive_assessment_category

  validates :point, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 5
  }
  validates :answered_at, presence: true
  validates :comprehensive_assessment_question_id, uniqueness: {
    scope: :comprehensive_assessment_test_id,
    message: 'can only be answered once per test'
  }

  # Validate that the category matches the question's category
  validate :category_matches_question

  scope :by_category, ->(category) { where(comprehensive_assessment_category: category) }
  scope :ordered, -> { order(:answered_at) }

  private

  def category_matches_question
    return unless comprehensive_assessment_question && comprehensive_assessment_category

    if comprehensive_assessment_question.comprehensive_assessment_category_id != comprehensive_assessment_category.id
      errors.add(:comprehensive_assessment_category_id, "must match the question's category")
    end
  end
end
