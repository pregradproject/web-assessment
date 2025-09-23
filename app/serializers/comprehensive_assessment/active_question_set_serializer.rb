module ComprehensiveAssessment
  class ActiveQuestionSetSerializer < ApplicationSerializer
    attributes(
      :id,
      :name,
      :version,
      :time_limit,
      :created_at
    )

    attribute :questions do |object|
      object.comprehensive_assessment_questions.map do |question|
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
