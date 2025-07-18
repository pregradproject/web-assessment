class AiKnowledgeQuestionSetCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id active created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[ai_knowledge_category ai_knowledge_question_set]
  end

  belongs_to :ai_knowledge_question_set
  belongs_to :ai_knowledge_category
end