module BehavioralLearning
  class TestResultsSerializer < ApplicationSerializer
    attributes(
      :total_score,
      :total_questions,
      :average_score,
      :level_label,
      :level_message,
      :threshold_min,
      :threshold_max
    )

    attribute :scores_breakdown do |object|
      categories = BehavioralLearningCategory.all.index_by(&:code)

      [
        {
          category: 'Motivation',
          code: 'M',
          score: object.category_score('M'),
          average: object.category_average('M'),
          description: categories['M']&.description
        },
        {
          category: 'Engagement',
          code: 'A',
          score: object.category_score('A'),
          average: object.category_average('A'),
          description: categories['A']&.description
        },
        {
          category: 'Learning Habits',
          code: 'H',
          score: object.category_score('H'),
          average: object.category_average('H'),
          description: categories['H']&.description
        },
        {
          category: 'Self-Regulation',
          code: 'R',
          score: object.category_score('R'),
          average: object.category_average('R'),
          description: categories['R']&.description
        }
      ]
    end

    attribute :performance_level do |object|
      case object.average_score
      when 0..2.0
        'Needs Improvement'
      when 2.01..3.5
        'Developing'
      when 3.51..4.5
        'Proficient'
      when 4.51..5.0
        'Excellent'
      else
        'Unknown'
      end
    end

    attribute :recommendations do |object|
      recommendations = []

      object.category_averages.each do |category_code, average|
        category_name = BehavioralLearningCategory.find_by(code: category_code)&.name

        case average
        when 0..2.5
          recommendations << "Focus on improving #{category_name} skills through targeted exercises and practice."
        when 2.51..3.5
          recommendations << "Continue developing #{category_name} abilities with consistent effort."
        when 3.51..5.0
          recommendations << "Maintain your strong #{category_name} skills and help others in this area."
        end
      end

      recommendations
    end

    attribute :detailed_analysis do |object|
      {
        strengths: object.strongest_categories,
        areas_for_improvement: object.weakest_categories,
        overall_assessment: "Your overall behavioral learning score is #{object.average_score.round(2)} out of 5.0, indicating #{object.level_label} performance.",
        next_steps: object.level_message
      }
    end
  end
end
