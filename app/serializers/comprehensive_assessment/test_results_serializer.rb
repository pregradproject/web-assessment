module ComprehensiveAssessment
  class TestResultsSerializer < ApplicationSerializer
    attributes(
      :id,
      :total_score,
      :total_questions,
      :average_score,
      :level_label,
      :level_message,
      :created_at
    )

    attribute :category_scores do |object|
      {
        cf: object.category_average('CF'),
        r: object.category_average('R'),
        e: object.category_average('E'),
        ag: object.category_average('AG'),
        ma: object.category_average('MA')
      }
    end

    attribute :category_breakdown do |object|
      object.category_breakdown
    end

    attribute :strongest_categories do |object|
      object.strongest_categories
    end

    attribute :weakest_categories do |object|
      object.weakest_categories
    end

    attribute :detailed_analysis do |object|
      object.detailed_result_data
    end

    attribute :test_info do |object|
      {
        id: object.comprehensive_assessment_test.id,
        completed_at: object.comprehensive_assessment_test.completed_at,
        question_set: {
          id: object.comprehensive_assessment_test.comprehensive_assessment_question_set.id,
          name: object.comprehensive_assessment_test.comprehensive_assessment_question_set.name,
          version: object.comprehensive_assessment_test.comprehensive_assessment_question_set.version
        }
      }
    end
  end
end
