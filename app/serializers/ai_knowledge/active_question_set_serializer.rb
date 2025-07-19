module AiKnowledge
  class ActiveQuestionSetSerializer < ApplicationSerializer
    attributes(
      :id,
      :version,
      :name,
      :active,
      :created_at,
      :updated_at,
      :time_limit
    )

    attribute :questions do |object|
      object.ai_knowledge_questions.map do |question|
        {
          id: question.id,
          body: question.body,
          max_weight: question.max_weight,
          category: {
            id: question.ai_knowledge_category.id,
            code: question.ai_knowledge_category.code,
            name: question.ai_knowledge_category.name
          }
        }
      end
    end
  end
end
