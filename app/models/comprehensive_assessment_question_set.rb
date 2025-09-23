class ComprehensiveAssessmentQuestionSet < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[created_at id started_at status updated_at user_id comprehensive_assessment_question_set_id version name active time_limit]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[comprehensive_assessment_questions comprehensive_assessment_question_set_categories comprehensive_assessment_tests comprehensive_assessment_categories]
  end

  has_many :comprehensive_assessment_questions, dependent: :destroy
  has_many :comprehensive_assessment_tests, dependent: :destroy
  has_many :comprehensive_assessment_question_set_categories, dependent: :destroy
  has_many :comprehensive_assessment_categories, through: :comprehensive_assessment_question_set_categories

  scope :active, -> { where(active: true).order(created_at: :desc) }
  scope :current_active, -> { where(active: true).order(created_at: :desc).first }

  def total_questions
    comprehensive_assessment_questions.count
  end

  def questions_by_category
    comprehensive_assessment_questions.includes(:comprehensive_assessment_category).group_by(&:comprehensive_assessment_category)
  end
end
