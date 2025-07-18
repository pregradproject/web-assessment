class AiKnowledgeQuestionSet < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[completed_at created_at id started_at status updated_at user_id ai_knowledge_question_set_id version name active time_limit]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[ai_knowledge_questions ai_knowledge_question_set_categories ai_knowledge_tests ai_knowledge_categories]
  end

  has_many :ai_knowledge_questions, dependent: :destroy
  has_many :ai_knowledge_tests, dependent: :destroy
  has_many :ai_knowledge_question_set_categories, dependent: :destroy
  has_many :ai_knowledge_categories, through: :ai_knowledge_question_set_categories

  scope :active, -> { where(active: true).order(created_at: :desc) }
  scope :current_active, -> { where(active: true).order(created_at: :desc).first }

  def total_questions
    ai_knowledge_questions.count
  end

  def questions_by_category
    ai_knowledge_questions.includes(:ai_knowledge_category).group_by(&:ai_knowledge_category)
  end
end
