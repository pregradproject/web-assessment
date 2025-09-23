class ComprehensiveAssessmentQuestion < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id body created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[comprehensive_assessment_category comprehensive_assessment_question_set]
  end

  belongs_to :comprehensive_assessment_question_set
  belongs_to :comprehensive_assessment_category
  has_many :comprehensive_assessment_test_answers, dependent: :destroy

  scope :by_category, ->(category) { where(comprehensive_assessment_category: category) }
  scope :ordered, -> { order(:created_at) }
end
