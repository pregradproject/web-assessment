class ComprehensiveAssessmentCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id code name description created_at updated_at]
  end

  has_many :comprehensive_assessment_questions, dependent: :destroy
  has_many :comprehensive_assessment_test_answers, dependent: :destroy
  has_many :comprehensive_assessment_question_set_categories, dependent: :destroy
  has_many :comprehensive_assessment_question_sets, through: :comprehensive_assessment_question_set_categories

  validates :code, presence: true, uniqueness: true, inclusion: { in: %w[CF R E AG MA] }
  validates :name, presence: true

  scope :ordered, -> { order(:code) }

  def self.cognitive_flexibility
    find_by(code: 'CF')
  end

  def self.resilience
    find_by(code: 'R')
  end

  def self.self_esteem
    find_by(code: 'E')
  end

  def self.academic_grit
    find_by(code: 'AG')
  end

  def self.metacognitive_awareness
    find_by(code: 'MA')
  end
end
