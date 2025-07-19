module AiKnowledge
  class TestResultsSerializer < ApplicationSerializer
    attributes(
      :performance_expectancy_score,
      :effort_expectancy_score,
      :social_influence_score,
      :facilitating_conditions_score,
      :hedonic_motivation_score,
      :price_value_score,
      :habit_score,
      :behavioral_intention_score,
      :min_score,
      :max_score
    )

    attribute :total_score do |object|
      object.total_score
    end

    attribute :scores_breakdown do |object|
      [
        {
          category: 'Performance Expectancy',
          code: 'PE',
          score: object.performance_expectancy_score,
          percentage: object.percentage_for_category('PE')
        },
        {
          category: 'Effort Expectancy',
          code: 'EE',
          score: object.effort_expectancy_score,
          percentage: object.percentage_for_category('EE')
        },
        {
          category: 'Social Influence',
          code: 'SI',
          score: object.social_influence_score,
          percentage: object.percentage_for_category('SI')
        },
        {
          category: 'Facilitating Conditions',
          code: 'FC',
          score: object.facilitating_conditions_score,
          percentage: object.percentage_for_category('FC')
        },
        {
          category: 'Hedonic Motivation',
          code: 'HM',
          score: object.hedonic_motivation_score,
          percentage: object.percentage_for_category('HM')
        },
        {
          category: 'Price Value',
          code: 'PV',
          score: object.price_value_score,
          percentage: object.percentage_for_category('PV')
        },
        {
          category: 'Habit',
          code: 'HT',
          score: object.habit_score,
          percentage: object.percentage_for_category('HT')
        },
        {
          category: 'Behavioral Intention',
          code: 'BI',
          score: object.behavioral_intention_score,
          percentage: object.percentage_for_category('BI')
        }
      ]
    end

    attribute :dominant_learning_styles do |object|
      object.dominant_learning_styles
    end

    attribute :learning_style_interpretation do |object|
      categories = AiKnowledgeCategory.all.index_by(&:code)

      {
        performance_expectancy: categories['PE']&.result_text,
        effort_expectancy: categories['EE']&.result_text,
        social_influence: categories['SI']&.result_text,
        facilitating_conditions: categories['FC']&.result_text,
        hedonic_motivation: categories['HM']&.result_text,
        price_value: categories['PV']&.result_text,
        habit: categories['HT']&.result_text,
        behavioral_intention: categories['BI']&.result_text
      }
    end

    # New comprehensive result description
    attribute :result_description do |object|
      detailed_data = object.detailed_result_data

      {
        title: detailed_data[:title],
        description: detailed_data[:description],
        characteristics: detailed_data[:characteristics],
        study_recommendations: detailed_data[:study_recommendations],
        strengths: detailed_data[:strengths],
        potential_challenges: detailed_data[:potential_challenges],
        career_suggestions: detailed_data[:career_suggestions],
        style_type: detailed_data[:style_type],
        learning_styles: detailed_data[:learning_styles],
        multimodal: detailed_data[:multimodal]
      }
    end
  end
end
