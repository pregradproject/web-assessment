class AiKnowledgeResultLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id min_score max_score performance_expectancy_score effort_expectancy_score social_influence_score facilitating_conditions_score hedonic_motivation_score price_value_score habit_score behavioral_intention_score created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[ai_knowledge_test user]
  end

  belongs_to :ai_knowledge_test
  belongs_to :user

  def total_score
    (performance_expectancy_score || 0) + (effort_expectancy_score || 0) +
    (social_influence_score || 0) + (facilitating_conditions_score || 0) +
    (hedonic_motivation_score || 0) + (price_value_score || 0) +
    (habit_score || 0) + (behavioral_intention_score || 0)
  end

  def scores_as_hash
    {
      'PE' => performance_expectancy_score || 0,
      'EE' => effort_expectancy_score || 0,
      'SI' => social_influence_score || 0,
      'FC' => facilitating_conditions_score || 0,
      'HM' => hedonic_motivation_score || 0,
      'PV' => price_value_score || 0,
      'HT' => habit_score || 0,
      'BI' => behavioral_intention_score || 0
    }
  end

  def dominant_learning_styles
    scores = scores_as_hash
    max_score = scores.values.max

    dominant_codes = scores.select { |_, score| score == max_score }.keys
    category_names = {
      'PE' => 'Performance Expectancy',
      'EE' => 'Effort Expectancy',
      'SI' => 'Social Influence',
      'FC' => 'Facilitating Conditions',
      'HM' => 'Hedonic Motivation',
      'PV' => 'Price Value',
      'HT' => 'Habit',
      'BI' => 'Behavioral Intention'
    }

    dominant_codes.map { |code| category_names[code] }
  end

  def score_for_category(code)
    scores_as_hash[code.upcase]
  end

  def percentage_for_category(code)
    return 0 if total_score.zero?

    score = score_for_category(code)
    ((score.to_f / total_score) * 100).round(1)
  end

  def result_description
    @result_description ||= AiKnowledge::ResultDescriptionMatcher.new(dominant_learning_styles, self).call
  end

  def detailed_result_data
    description = result_description

    {
      title: description.title,
      description: description.description,
      characteristics: description.characteristics,
      study_recommendations: description.study_recommendations,
      strengths: description.strengths,
      potential_challenges: description.potential_challenges,
      career_suggestions: description.career_suggestions,
      style_type: description.respond_to?(:style_type) ? description.style_type : 'Unknown',
      learning_styles: description.respond_to?(:learning_styles) ? description.learning_styles : dominant_learning_styles,
      multimodal: description.respond_to?(:multimodal?) ? description.multimodal? : dominant_learning_styles.length > 1,
      score_percentages: {
        performance_expectancy: percentage_for_category('PE'),
        effort_expectancy: percentage_for_category('EE'),
        social_influence: percentage_for_category('SI'),
        facilitating_conditions: percentage_for_category('FC'),
        hedonic_motivation: percentage_for_category('HM'),
        price_value: percentage_for_category('PV'),
        habit: percentage_for_category('HT'),
        behavioral_intention: percentage_for_category('BI')
      }
    }
  end
end
