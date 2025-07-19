module AiKnowledge
  module QuestionListSerializer
    extend ActiveSupport::Concern

    class_methods do
      def question_list(questions)
        questions.map do |question|
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

  class TestSerializer < ApplicationSerializer
    include QuestionListSerializer
    attributes(
      :id,
      :started_at,
      :completed_at,
      :status
    )

    attribute :time_limit do |object|
      object.ai_knowledge_question_set.time_limit
    end

    attribute :expires_at do |object|
      object.started_at + object.ai_knowledge_question_set.time_limit.seconds
    end

    attribute :questions do |object|
      question_list(object.ai_knowledge_question_set.ai_knowledge_questions)
    end
  end
end
