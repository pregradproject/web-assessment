class ComprehensiveAssessmentQuestionSetCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id created_at updated_at comprehensive_assessment_question_set_id comprehensive_assessment_category_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[comprehensive_assessment_question_set comprehensive_assessment_category]
  end

  belongs_to :comprehensive_assessment_question_set
  belongs_to :comprehensive_assessment_category

  validates :comprehensive_assessment_question_set_id, uniqueness: {
    scope: :comprehensive_assessment_category_id,
    message: 'Category already exists for this question set'
  }
end
