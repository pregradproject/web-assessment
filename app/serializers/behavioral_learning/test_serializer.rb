module BehavioralLearning
  module QuestionListSerializer
    extend ActiveSupport::Concern

    class_methods do
      def question_list(questions)
        questions.map do |question|
          {
            id: question.id,
            body: question.body,
            category: {
              id: question.behavioral_learning_category.id,
              code: question.behavioral_learning_category.code,
              name: question.behavioral_learning_category.name
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
      object.behavioral_learning_question_set.time_limit
    end

    attribute :expires_at do |object|
      object.started_at + object.behavioral_learning_question_set.time_limit.seconds
    end

    attribute :questions do |object|
      question_list(object.behavioral_learning_question_set.behavioral_learning_questions)
    end
  end
end
