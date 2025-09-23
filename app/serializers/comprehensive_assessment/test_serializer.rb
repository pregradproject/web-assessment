module ComprehensiveAssessment
  module QuestionListSerializer
    extend ActiveSupport::Concern

    class_methods do
      def question_list(questions)
        questions.map do |question|
          {
            id: question.id,
            body: question.body,
            category: {
              id: question.comprehensive_assessment_category.id,
              code: question.comprehensive_assessment_category.code,
              name: question.comprehensive_assessment_category.name
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
      object.comprehensive_assessment_question_set.time_limit
    end

    attribute :expires_at do |object|
      object.started_at + object.comprehensive_assessment_question_set.time_limit.seconds
    end

    attribute :questions do |object|
      question_list(object.comprehensive_assessment_question_set.comprehensive_assessment_questions)
    end
  end
end
