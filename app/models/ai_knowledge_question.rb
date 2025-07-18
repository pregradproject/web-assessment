class AiKnowledgeQuestion < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id body created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[ai_knowledge_category ai_knowledge_question_set]
  end

  belongs_to :ai_knowledge_question_set
  belongs_to :ai_knowledge_category
  has_many :ai_knowledge_test_answers, dependent: :destroy

  scope :by_category, ->(category) { where(ai_knowledge_category: category) }
  scope :ordered, -> { order(:created_at) }
end
