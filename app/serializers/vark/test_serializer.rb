module Vark
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
              id: question.vark_category.id,
              code: question.vark_category.code,
              name: question.vark_category.name
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
      object.vark_question_set.time_limit
    end

    attribute :expires_at do |object|
      object.started_at + object.vark_question_set.time_limit.seconds
    end

    attribute :questions do |object|
      question_list(object.vark_question_set.vark_questions)
    end
  end
end
