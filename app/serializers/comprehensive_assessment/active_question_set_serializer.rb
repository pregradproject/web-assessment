module ComprehensiveAssessment
  class ActiveQuestionSetSerializer < ApplicationSerializer
    include QuestionListSerializer
    attributes(
      :id,
      :name,
      :version,
      :time_limit,
      :created_at
    )

    attribute :questions do |object|
      question_list(object.comprehensive_assessment_questions)
    end

    attribute :categories do |object|
      object.comprehensive_assessment_categories.map do |category|
        {
          id: category.id,
          code: category.code,
          name: category.name,
          description: category.description
        }
      end
    end

    attribute :total_questions do |object|
      object.total_questions
    end
  end
end
