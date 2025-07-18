class AiKnowledgeCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id code name description result_text created_at updated_at]
  end

  has_many :ai_knowledge_questions, dependent: :destroy
  has_many :ai_knowledge_test_answers, dependent: :destroy
  has_many :ai_knowledge_question_set_categories, dependent: :destroy
  has_many :ai_knowledge_question_sets, through: :ai_knowledge_question_set_categories

  scope :ordered, -> { order(:code) }

  def self.performance_expectancy
    find_by(code: 'PE')
  end

  def self.effort_expectancy
    find_by(code: 'EE')
  end

  def self.social_influence
    find_by(code: 'SI')
  end

  def self.facilitating_conditions
    find_by(code: 'FC')
  end

  def self.hedonic_motivation
    find_by(code: 'HM')
  end

  def self.price_value
    find_by(code: 'PV')
  end

  def self.habit
    find_by(code: 'HT')
  end

  def self.behavioral_intention
    find_by(code: 'BI')
  end
end
